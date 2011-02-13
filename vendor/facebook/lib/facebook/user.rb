class Facebook
  class User
    attr_reader :id, :access_token

    def initialize(id, access_token=nil)
      Integer(@id = id)
      @access_token = access_token
    end

    def api(suffix, params={}, method="GET")
      params[:access_token] = @access_token
      Facebook.get("/#{facebook.id}/#{suffix}", params, method)
    end
    alias_method :get, :api
  end
end
