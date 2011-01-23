require 'sinatra'

path = File.expand_path "..", __FILE__
require path+"/loversapp.rb"

run Sinatra::Application
