require 'bundler'
Bundler.setup(:default, (ENV["RACK_ENV"] || "development").to_sym)

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), "lib"))
require 'lovers'

use Sinatra::ShowExceptions if Lovers.env == "development"
run Lovers::Server
