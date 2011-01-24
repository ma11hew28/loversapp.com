ENV["RACK_ENV"] = "cucumber"

require "rubygems"
require "bundler"
Bundler.setup(:default, :cucumber)

require 'ruby-debug'
require 'rspec-expectations'
require 'capybara/cucumber'

$LOAD_PATH << File.expand_path("../../../lib", __FILE__)

require 'lovers'

Capybara.default_driver = :rack_test
Capybara.app = Lovers::Server
