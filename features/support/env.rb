ENV["RACK_ENV"] = "cucumber"

require "rubygems"
require "bundler"
Bundler.setup(:default, :cucumber)

require 'ruby-debug'
require 'rspec-expectations'
require 'capybara/cucumber'

$LOAD_PATH << File.expand_path("../../../lib", __FILE__)
$LOAD_PATH << File.expand_path("..", __FILE__)

require 'lovers'
require 'lovers_test'

Capybara.default_driver = :rack_test
Capybara.app = Lovers::Server

require 'redis_test_setup'
RedisTestSetup.start_redis!(:cucumber)
