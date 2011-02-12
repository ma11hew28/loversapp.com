require 'sinatra/base'
require 'erb' # use Erb templates

class Lovers::Application < Sinatra::Base

  ##############################################################################
  # Configure ##################################################################
  ##############################################################################

  # This should go in a file outside of ./lib/ since it's special configuration.
  # I put it in config.ru, but cucumber doesn't load that.
  require 'logger'
  Lovers.logger = Logger.new(STDOUT)

  configure :development do
    require 'ruby-debug'
  end

  before "/fb/canvas/r*" do
    content_type "application/json"
    @user = Lovers::User.auth(request.cookies["u"])
  end

  set :show_exceptions, false

  error do
    begin
      e = request.env["sinatra.error"]
      Lovers.logger.error e.inspect
      e.class::CODE
    rescue
      Lovers::UnknownError::CODE
    end
  end

  helpers do
    def auth_url
      url    = Rack::Utils.escape(Lovers.facebook.canvas_page)
      base   = "https://www.facebook.com/dialog/oauth"
      params = "?client_id=#{Lovers.facebook.id}&redirect_uri=#{url}"
      "#{base}#{params}"
    end

    def rel_code(rtype)
      @code_hash_for_user ||= Lovers::Relationship.code_hash_for_user(@user.facebook.user_id)
      @code_hash_for_user[rtype]
    end

    def user_access_token
      @user && @user.facebook && @user.facebook.access_token
    end

    # Make sure the browser only caches the latest version of static files.
    # Taken from: http://agib.me/edwfXX
    def versioned_stylesheet(stylesheet)
      ts_path('stylesheets', "#{stylesheet}.css")
    end

    def versioned_javascript(js)
      ts_path('javascripts', "#{js}.js")
    end
  end


  ##############################################################################
  # Canvas #####################################################################
  ##############################################################################

  # Developement
  get "/fb/canvas/" do
    # puts $LOAD_PATH
    # params[:signed_request] = Facebook::Test::APP_USER[:signed_request]
    @user = User.new("514417")
    erb :canvas
    # erb :login
  end

  # Initial Facebook request comes in as a POST with a signed_request.
  post "/fb/canvas/" do
    # If we do cache control, I don't think the cookie will get set.
    # cache_control :public, max_age: 31536000 # seconds (1 year)

    unless (@user = Lovers::User.auth(params[:signed_request])).facebook.nil?
      # Remember user for 1 day for future AJAX requests.
      # No expires: cookie lasts til browser closes or user deletes it.
      # This works cause FB POSTs signed_request everytime app loads in browser.
      # On server, however, to limit use of hijacked session, let's verify that
      # cookie is less than 1 day old via session["issued_at"].
      response.set_cookie "u",
        Lovers.facebook.user_cookie(@user.facebook.user_id)
      # Rack provides signed cookies (below) but signs them differently than
      # Facebook. So, I wrote our own methods to sign the cookie like Facebook.
      # use Rack::Session::Cookie, domain: facebook.canvas_page,
      #                            secret: facebook.secret
      erb :canvas
    else
      erb :login
    end
  end

  post "/fb/deauth" do
    Lovers::User.auth!(params[:signed_request]).delete
  end

  post "/fb/canvas/admin" do
    user = Lovers::User.auth!(params[:signed_request])
    unless Lovers::Conf.admin_uids.include? user.facebook.user_id
      return redirect "/fb/canvas/"
    end
    @users = Lovers.redis.smembers("users")
    @alums = Lovers.redis.smembers("alums")
    erb :admin, layout: false
  end


  ##############################################################################
  # Credits ####################################################################
  ##############################################################################

  # http://developers.facebook.com/docs/creditsapi
  post "/fb/credits/callback" do
    debugger
    credits = Lovers.facebook.decode_signed_request(
      params[:signed_request])["credits"]
    method = params[:method]
    order_id = credits["order_id"]
    response = {method: method}

    case method
    when "payments_get_itmes"
      order = credits["order_info"] # key to get item from database
      response[:content] = [Lovers::Gift.find(order["gift_id"])]
    when "payments_status_update"
      response[:content] = {}
      case credits["status"]
      when "placed", "settled"
        response[:content][:status] = "settled"
      when "settled"
        order = credits["order_details"]
        User.new(order["from_id"]).send_gift(order["gift_id"], order["to_id"])
      end
      response[:content][:order_id] = order_id
    end
    response.to_json
  end


  ##############################################################################
  # Share ######################################################################
  ##############################################################################
  # Facebook Stream API
  # - Show all my friends posts
  # - Show all posts


  ##############################################################################
  # Relationships ##############################################################
  ##############################################################################

  # GET (show) all relationships for a user.
  get "/fb/canvas/relationships" do
    @user.relationships.to_s
  end

  # POST (confirm/add) a relationship between two users.
  post "/fb/canvas/relationship" do
    @user.accept_requests(validate_rid_uid(params[:rid], params[:uid]))
  end

  # DELETE (break up) a relationship.
  delete "/fb/canvas/relationship" do
    @user.remove_relationship(validate_rid_uid(params[:rid], params[:uid]))
  end


  ##############################################################################
  # Utility Methods ############################################################
  ##############################################################################

  # Validate that tid & rid are integers and rid is btw 0 to Lovers::Conf.reln.
  def validate_rid_uid(rid, uid)
    [validate_rid(rid), validate_uid(uid)]
  end

  # Validate that rid is an integer between 0 & Lovers::Conf.reln, inclusive.
  def validate_rid(rid)
    rid = Integer(rid)
    raise if rid < 0 || Lovers::Conf.reln <= rid
    rid
  rescue
    raise Lovers::RequestIdInvalid
  end

  def validate_uid(uid)
    Integer(uid) rescue raise Lovers::TargetIdInvalid
  end

  def ts_path(dir, file)
    "/#{dir}/#{file}?" + ts_file(dir, file).to_i.to_s
  end

  def ts_file(dir, file)
    File.mtime(File.join(Lovers.root, 'public', dir, file))
  end
  # @staticmethod
  # def base64_url_encode(data):
  #     return base64.urlsafe_b64encode(data).rstrip("=")


  # Cool projects
  # mechanical turk
  # patch
  # locomotive
  # omniauth
  # mjording
  # nyc-ruby-meetup

  # Specs: It should:
  # Redis

  # Questions
end
