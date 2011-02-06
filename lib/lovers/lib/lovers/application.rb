require 'sinatra/base'
require 'erb' # use Erb templates

class Lovers::Application < Sinatra::Base
  attr_reader :facebook

  def initialize(app=nil)
    @facebook = Facebook::Application.new(
      Lovers::Conf.fb_app_id,
      Lovers::Conf.fb_app_secret,
      Lovers::Conf.fb_canvas_name)
    super(app)
  end

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
    @user = Lovers::User.new(session["u"])
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
    def canvas_url
      "http://apps.facebook.com/#{Lovers::Conf.fb_canvas_name}/"
    end

    def auth_url
      url    = Rack::Utils.escape(canvas_url)
      base   = "https://www.facebook.com/dialog/oauth"
      params = "?client_id=#{Lovers::Conf.fb_app_id}&redirect_uri=#{url}"
      "#{base}#{params}"
    end

    def rel_code(rtype)
      @code_hash_for_user ||= Lovers::Relationship.code_hash_for_user(@user.facebook.user_id)
      @code_hash_for_user[rtype]
    end
  end


  ##############################################################################
  # Canvas #####################################################################
  ##############################################################################

  # Initial Facebook request comes in as a POST with a signed_request.
  post "/fb/canvas/" do
    # If we do cache control, I don't think the cookie will get set.
    # cache_control :public, max_age: 31536000 # seconds (1 year)

    if @user = Lovers::User.auth(params[:signed_request])
      # Remember user for 1 day for future AJAX requests.
      # No expires: cookie lasts til browser closes or user deletes it.
      # This works cause FB POSTs signed_request everytime app loads in browser.
      # On server, however, to limit use of hijacked session, let's verify that
      # cookie is less than 1 day old via session["issued_at"].
      response.set_cookie "u", value: @user.facebook.cookie, domain: facebook.canvas_page
      # Rack provides signed cookies (below) but signs them differently than
      # Facebook. So, I wrote our own methods to sign the cookie like Facebook.
      # use Rack::Session::Cookie, domain: facebook.canvas_page,
      #                            secret: facebook.app_secret
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
    credits = Lovers.fb.auth!(params[:signed_request])["credits"]
    method = params[:method]
    order_id = credits["order_id"]
    response = {method: method}

    case method
    when "payments_get_itmes"
      # order_info = credits["order_info"] # key to get item from database
      response[:content] = [{
        title: "Rose",
        description: "Happy Valentine's Day!",
        price: 10, # 10 credits = $1
        image_url: "http://www.facebook.com/images/gifts/10.png", # pink rose
        product_url: "http://www.facebook.com/images/gifts/10.png"
        # data: 3 # optional; stored on FB & included in order_details
      }]
      # cool fb gifts
      # 10: rose
      # 13: panties
      # 16: heart cookie w love written on it with icing
      # 1000: call me candy heart
    when "payments_status_update"
      response[:content] = {}
      if credits["status"] == "placed"
        response[:content][:status] = "settled"
      end
      response[:content][:order_id] = order_id;
    end
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
