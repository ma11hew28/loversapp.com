ENV["RACK_ENV"] = "cucumber"

require "bundler"
Bundler.setup(:default, :cucumber)

require 'ruby-debug'
require 'rspec-expectations'

$LOAD_PATH << File.expand_path("../../lib", __FILE__)
require 'facebook'
