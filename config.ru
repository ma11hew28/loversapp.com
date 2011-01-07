path = File.expand_path "../", __FILE__

require 'sinatra'
require 'redis'
require "#{path}/loversapp.rb"

run Sinatra::Application
