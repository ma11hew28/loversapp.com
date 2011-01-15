require 'redis' # for storing app_users, requests, relationships, etc.

# Facebook signed_request
require 'base64'
require 'hmac-sha2'

# This is probably not so polite. How do better?
class String
  def uncapitalize
    self[0].downcase + self[1..-1]
  end

  def pluralize
    self + 's'
  end
end

require 'lovers/conf' # set Facebook constants, etc.
require 'lovers/user'
require 'lovers/request'
require 'lovers/relationship'

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
