require 'openssl' # decode Facebook signed_request via HMAC-SHA256
require 'json'    # parse JSON signed_request & API responses

require 'facebook/errors'
require 'facebook/application'
require 'facebook/user'

module Facebook
  GRAPH_DOMAIN = "graph.facebook.com"

  class << self
    def application
      @@application ||= nil
    end

    def application=(application)
      @@application = application
    end

    def api(path, params={}, method="GET")
      params[:method] = method
      GRAPH_URL + path
    end
    alias_method :get, :api

    protected

    def encode_params(params={})
      params.map { |k, v| "#{k}=#{escape v}" }.join("&")
    end

    # File cgi/util.rb, line 6
    def escape(string)
      string.gsub(/([^ a-zA-Z0-9_.-]+)/) do
        '%' + $1.unpack('H2' * $1.bytesize).join('%').upcase
      end.tr(' ', '+')
    end
  end
end
FB = Facebook
