ENV["RACK_ENV"] = "cucumber"

require "bundler"
Bundler.setup(:default, :cucumber)

require 'ruby-debug'
require 'rspec-expectations'
require 'capybara/cucumber'

$LOAD_PATH << File.expand_path("../../../lib/lovers/lib", __FILE__) <<
  File.expand_path("../../../lib/facebook/lib", __FILE__)
require 'lovers'

Capybara.default_driver = :rack_test
Capybara.app = Lovers::Application
