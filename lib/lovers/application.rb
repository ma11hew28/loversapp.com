require 'sinatra/base'
require 'erb'          # use Erb templates
# require 'rdiscount'  # use markdown temlpates

module Lovers
  class Application < Sinatra::Base

    ############################################################################
    # Configure ################################################################
    ############################################################################

    set :root, Lovers.root

    # We should set logger in a config file outside of ./lib/.
    # I put it in config.ru, but cucumber doesn't load that.
    # Maybe we should use Sinatra's logger. See:
    # http://www.sinatrarb.com/configuration.html
    require 'logger'
    Lovers.logger = Logger.new(STDOUT)

    configure :development do
      require 'ruby-debug'
    end

    before "/fb/canvas/r*" do
      content_type "application/json"
      @user = User.auth(request.cookies["u"])
    end

    set :show_exceptions, false

    error do
      begin
        e = request.env["sinatra.error"]
        Lovers.logger.error e.inspect
        e.class::CODE
      rescue
        UnknownError::CODE
      end
    end

    helpers do
      # def rel_code(rtype)
      #   @code_hash_for_user ||= Relationship.code_hash_for_user(
      #     @user.facebook.id)
      #   @code_hash_for_user[rtype]
      # end

      # Make sure the browser only caches the latest version of static files.
      # Taken from: http://agib.me/edwfXX
      def versioned_stylesheet(stylesheet)
        mtimed_path('stylesheets', "#{stylesheet}.css")
      end

      def versioned_javascript(js)
        mtimed_path('javascripts', "#{js}.js")
      end
    end


    ############################################################################
    # Canvas ###################################################################
    ############################################################################

    get "/fb/canvas/about" do
      cache_control :public, max_age: 31536000 # seconds (1 year)
      @class = "login"
      erb :login
    end

    get "/fb/canvas/privacy" do
      cache_control :public, max_age: 31536000 # seconds (1 year)
      erb :privacy
    end

    get "/fb/canvas/faq" do
      cache_control :public, max_age: 31536000 # seconds (1 year)
      erb :faq
    end

    # Initial Facebook request comes in as a POST with a signed_request.
    post "/fb/canvas/" do
      # If we do cache control, I don't think the cookie will get set.
      # cache_control :public, max_age: 31536000 # seconds (1 year)

      unless (@user = User.auth(params[:signed_request])).facebook.nil?
        # Remember user for 1 day for future AJAX requests. No expires: cookie
        # lasts til browser closes or user deletes it. This works cause FB POSTs
        # signed_request everytime app loads in browser. On server, however, to
        # limit use of hijacked session, let's verify that cookie is less than 1
        # day old via session["issued_at"].
        # Rack provides signed cookies (below) but signs them differently than
        # Facebook. So, I made our own methods to sign the cookie like Facebook.
        # use Rack::Session::Cookie, domain: facebook.canvas_page,
        #                            secret: facebook.secret
        response.set_cookie "u",
          Lovers.facebook.user_cookie(@user.facebook.id)
        @class = "canvas"
        erb :canvas
      else
        @class = "login"
        erb :login
      end
    end

    post "/fb/deauth" do
      User.auth!(params[:signed_request]).delete
    end

    get "/fb/canvas/admin" do
      @user = User.auth!(request.cookies["u"])
      return redirect "/fb/canvas/" unless @user.admin?

      @user_count = User.count
      @users = User.paginate({page: params[:page].to_i, per_page: 3304})
      @alums = User.alums
      # User.calculate_points_once if user.facebook.id == User.admins[1]
      erb :admin
    end


    ############################################################################
    # Credits ##################################################################
    ############################################################################

    # http://developers.facebook.com/docs/creditsapi
    post "/fb/credits/callback" do
      require 'pp'
      puts "PARAMS: ====================="
      pp params
      request = Lovers.facebook.decode_signed_request(params[:signed_request])
      credits = request["credits"]
      puts "REQUEST: ====================="
      pp request
      method = params[:method]
      order_id = credits["order_id"]
      response = {method: method}

      puts "METHOD: " + method
      case method
      when "payments_get_items"
        order = JSON.parse credits["order_info"]
        gift = Gift.find(order["gift_id"]) # gift_id must be integer
        raise "to_id must be an integer" unless Integer(order["to_id"])
        gift["data"] = order["to_id"]
        response[:content] = [gift]
        # response[:receiver] = order["to_id"]
      when "payments_status_update"
        response[:content] = {}
        status = credits["status"]
        order = JSON.parse credits["order_details"]
        puts "ORDER: "
        pp order
        item = order["items"][0]
        to_id = Integer(item["data"])

        if status == "placed"
          puts "PLACED"
          # response[:receiver] = to_id
          response[:content][:status] = "settled"
        elsif status == "settled"
          puts "SETTLED"
          User.new(order["buyer"].to_s).send_gift(item["item_id"], to_id)
          puts "SENT GIFT #{item["item_id"]} from #{order["buyer"]} to #{to_id}."
        end
        response[:content][:order_id] = order_id
      end
      puts "RESPONSE: ====================="
      pp response
      response.to_json
    end


    ############################################################################
    # Share ####################################################################
    ############################################################################
    # Facebook Stream API
    # - Show all my friends posts
    # - Show all posts


    ############################################################################
    # Relationships ############################################################
    ############################################################################

    # GET (show) all relationships for a user.
    get "/fb/canvas/relationships" do
      @user.relationships.to_s
    end

    # POST (confirm/add) a relationship between two users.
    post "/fb/canvas/relationship" do
      @user.accept_requests(validate_request_id_user_id(
        params[:rid], params[:uid]))
    end

    # DELETE (break up) a relationship.
    delete "/fb/canvas/relationship" do
      @user.remove_relationship(
        validate_request_id_user_id(params[:rid], params[:uid]))
    end


    ############################################################################
    # Utility Methods ##########################################################
    ############################################################################

    # Validate that tid & rid are integers and rid is btw 0 to Conf.reln.
    def validate_request_id_user_id(rid, uid)
      [validate_request_id(rid), validate_user_id(uid)]
    end

    # Validate that rid is an integer between 0 & Conf.reln, inclusive.
    def validate_request_id(rid)
      rid = Integer(rid)
      raise if rid < 0 || Conf.reln <= rid
      rid
    rescue
      raise RequestIdInvalid
    end

    def validate_user_id(uid)
      Integer(uid) rescue raise TargetIdInvalid
    end

    def mtimed_path(dir, file)
      File.join("", dir, file) + "?" + file_mtime(dir, file).to_i.to_s
    end

    def file_mtime(dir, file)
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
end
