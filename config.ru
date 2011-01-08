path = File.expand_path "../", __FILE__

require 'sinatra'
require 'json'
require 'redis'

# Facebook signed_request
require 'base64'
require 'hmac-sha2'

require "#{path}/loversapp.rb"

run Sinatra::Application
