require 'redis' # for storing app_users, requests, relationships, etc.
require 'json'  # for JSON responses

# for decoding Facebook signed_request
require 'openssl'
require 'base64'

path = File.expand_path "../../lib/lovers", __FILE__
require path+"/conf" # set Facebook constants, etc.
require path+"/errors"
require path+"/user"
require path+"/rel"

module Lovers
  class << self
    def redis
      @@redis ||= if ENV["RACK_ENV"] == "production"
        uri = URI.parse(ENV["REDISTOGO_URL"])
        Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      elsif ENV["RACK_ENV"] == "cucumber"
        Redis.new(:port => 6398)
      elsif ENV["RACK_ENV"] == "test"
        Redis.new(:port => 6397)
      else
        Redis.new
      end
    end

    def root
      @root ||= File.expand_path("../..", __FILE__)
    end
  end
end
