require 'redis'    # store users, requests, relationships, etc.
require 'json'     # JSON decode/encode request params & responses
require 'logger'   # log errors
require 'facebook' # add a Facebook app

module Lovers
  class << self
    def redis
      @@redis ||= if env == "production" || env == "staging"
        uri = URI.parse(ENV["REDISTOGO_URL"])
        Redis.new({
          host: uri.host,
          port: uri.port,
          password: uri.password
        })
      elsif env == "cucumber"
        Redis.new(port: 6398)
      elsif env == "test"
        Redis.new(port: 6397)
      else
        Redis.new(port: ENV["REDIS_PORT"])
      end
    end

    def facebook
      @@facebook ||= Facebook.new(Lovers::Conf.fb_app_id,
        Lovers::Conf.fb_app_secret, Lovers::Conf.fb_canvas_name)
    end

    def root
      @@root ||= File.expand_path("../..", __FILE__)
    end

    def env
      @@env = ENV["RACK_ENV"] || "development"
    end

    def logger
      @@logger ||= nil
    end

    def logger=(logger)
      @@logger = logger
    end
  end
end

require 'lovers/conf'
require 'lovers/errors'
require 'lovers/user'
require 'lovers/relationship'
require 'lovers/gift'
require 'lovers/application'
