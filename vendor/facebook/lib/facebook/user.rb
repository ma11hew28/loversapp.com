class Facebook
  class User
    attr_reader :id, :access_token

    def initialize(id, access_token=nil)
      Integer(@id = id)
      @access_token = access_token
    end

    def apprequests
      @apprequests ||= get("apprequests")
    end
    alias_method :requests, :apprequests

    def api(suffix="", params={}, method="GET")
      path = "/#{id}"; path << "/#{suffix}" unless suffix.empty?
      params[:access_token] = @access_token if @access_token
      Facebook.api(path, params, method)
    end
    alias_method :get, :api
  end
end
