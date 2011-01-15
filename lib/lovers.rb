# Facebook signed_request
require 'base64'
require 'hmac-sha2'

require 'lovers/conf' # set Facebook constants, etc.
require 'lovers/user'
require 'lovers/request'

module Lovers
  class << self
    def redis
      @@redis ||= if ENV["RACK_ENV"] == "production"
        uri = URI.parse(ENV["REDISTOGO_URL"])
        Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      else
        Redis.new
      end
    end
  end
end
