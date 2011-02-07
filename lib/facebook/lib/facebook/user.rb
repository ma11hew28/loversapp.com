module Facebook
  class User
    attr_reader :user_id, :access_token

    def initialize(user_id, access_token=nil)
      Integer(@user_id = user_id)
      @access_token = access_token
    end

    def cookie
      @cookie ||= Facebook.application.encode_data({
        user_id: user_id, issued_at: Time.now.to_i+86400})
    end

    def api(suffix, params={}, method="GET")
      params[:access_token] = @access_token
      Facebook.get("/#{facebook.user_id}/#{suffix}", params, method)
    end
    alias_method :get, :api
  end
end
