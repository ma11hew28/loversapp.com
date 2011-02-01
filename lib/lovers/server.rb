require 'sinatra/base'
require 'erb' # use Erb templates

class Lovers::Server < Sinatra::Base

  ##############################################################################
  # Configure ##################################################################
  ##############################################################################

  configure :development do
    require 'ruby-debug'
  end

  # enable :sessions # cookie-based sessions - method below allows more options
  # No expires: cookie lasts til browser closes or user deletes it.
  # This works cause FB POSTs signed_request everytime app loads in browser.
  # On server, however, to limit use of hijacked session, let's verify that
  # cookie is less than 1 day old via session["t"].
  # Note: Should we roll our own session implementation, using Facebook's
  # signing method, so that we can use auth both for session & cookie?
  use Rack::Session::Cookie, :domain => Lovers::Conf.fb_canvas_page,
                             :secret => Lovers::Conf.fb_app_secret

  before '/fb/canvas/r*' do
    content_type 'application/json'
    @user = Lovers::User.new(session["u"])
  end

  set :show_exceptions, false

  error do
    begin
      e = request.env['sinatra.error']
      Lovers.logger << e.inspect
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
      base   = 'https://www.facebook.com/dialog/oauth'
      params = "?client_id=#{Lovers::Conf.fb_app_id}&redirect_uri=#{url}"
      "#{base}#{params}"
    end

    def rel_code(rtype)
      @code_hash_for_user ||= Lovers::Rel.code_hash_for_user(@user.fb_id)
      @code_hash_for_user[rtype]
    end
  end

  ##############################################################################
  # Canvas #####################################################################
  ##############################################################################

  # Initial Facebook request comes in as a POST with a signed_request.
  post '/fb/canvas/' do
    # If we do cache control, I don't think the cookie will get set.
    # cache_control :public, :max_age => 31536000 # seconds (1 year)

    if @user = Lovers::User.auth(params[:signed_request])
      # Remember user for 1 day for future AJAX requests.
      session["u"], session["t"] = @user.fb_id, Time.now.to_i+86400
      erb :canvas
    else
      erb :login
    end
  end

  post '/fb/deauth' do
    Lovers::User.auth!(params[:signed_request]).rem_app_user  
  end

  post '/fb/canvas/admin' do
    user = Lovers::User.auth!(params[:signed_request])
    unless Lovers::Conf.admin_uids.include? user.fb_id
      return redirect "/fb/canvas/"
    end
    @appUsrs = Lovers.redis.smembers("appUsrs")
    @oldUsrs = Lovers.redis.smembers("oldUsrs")
    erb :admin, :layout => false
  end
  

  ##############################################################################
  # Share ######################################################################
  ##############################################################################
  # Facebook Stream API
  # - Show all my friends posts
  # - Show all posts


  ##############################################################################
  # Requests ###################################################################
  ##############################################################################
  # How can we manage requests on Facebook? If we can set a type for each sent
  # request and get & delete them, then we could replace this request code.
  #
  # Each user has two Redis sorted sets (`reqSent` & `reqRecv`) that store uids.
  # The SCORE that we order the requests by is `time` (UNIX timestamp).
  # The request id (rid) is encoded as number and prepended to the uid. rid|uid
  #
  # E.g., for the user with uid=100, we might have:
  #   100:reqSent => ["1|123", "2|123", "2|134"]  # format: ["rid|tid"]
  #   100:reqRecv => ["3|343", "5|142", "4|2224"] # format: ["rid|uid"]

  # GET (show) received & hidden requests for a user.
  get '/fb/canvas/reqs' do
    @user.reqs.to_json
  end

  # POST (add) a request from one user (uid) to another (tid)
  post '/fb/canvas/req' do
    @user.send_req(validate_rid_uid(params[:rid], params[:tid]))
  end

  # DELETE (ignore) a request.
  delete '/fb/canvas/req' do
    @user.remv_req(validate_rid_uid(params[:rid], params[:uid]))
  end


  ##############################################################################
  # Relationships ##############################################################
  ##############################################################################

  # GET (show) all relationships for a user.
  get '/fb/canvas/rels' do
    @user.rels.inspect
  end

  # POST (confirm/add) a relationship between two users.
  post '/fb/canvas/rel' do
    @user.conf_req(validate_rid_uid(params[:rid], params[:uid]))
  end

  # DELETE (break up) a relationship.
  delete '/fb/canvas/rel' do
    @user.remv_rel(validate_rid_uid(params[:rid], params[:uid]))
  end


  ##############################################################################
  # Utility Methods ############################################################
  ##############################################################################

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

  # Validate that tid & rid are integers and rid is btw 0 to Lovers::Conf.reln.
  def validate_rid_uid(rid, uid)
    [validate_rid(rid), validate_uid(uid)]
  end

  # @staticmethod
  # def base64_url_encode(data):
  #     return base64.urlsafe_b64encode(data).rstrip('=')


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
