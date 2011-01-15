path = File.expand_path "../", __FILE__

require 'sinatra'
require 'json'
require 'redis'

require "#{path}/loversapp.rb"

run Sinatra::Application
