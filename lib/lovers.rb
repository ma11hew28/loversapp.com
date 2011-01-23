require 'redis' # for storing app_users, requests, relationships, etc.
require 'json'  # for JSON responses

# for decoding Facebook signed_request
require 'openssl'
require 'base64'

module Lovers
  class << self
    def redis
      @@redis ||= if env == "production"
        uri = URI.parse(ENV["REDISTOGO_URL"])
        Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      elsif env == "cucumber"
        Redis.new(:port => 6398)
      elsif env == "test"
        Redis.new(:port => 6397)
      else
        Redis.new
      end
    end

    def root
      @root ||= File.expand_path("../..", __FILE__)
    end

    def env
      ENV["RACK_ENV"] || "development"
    end
  end
end

require "lovers/conf"
require "lovers/errors"
require "lovers/user"
require "lovers/rel"
require "lovers/server"
