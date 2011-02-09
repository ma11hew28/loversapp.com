ENV["RACK_ENV"] = "cucumber"

require 'bundler'
Bundler.setup(:default, :cucumber)

require 'ruby-debug'

$LOAD_PATH << File.expand_path(File.join(
  File.dirname(__FILE__), "..", "..", "lib"))
require 'facebook'
