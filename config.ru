path = File.expand_path "..", __FILE__

require 'sinatra'
require 'json'

require path+"/loversapp.rb"

run Sinatra::Application
