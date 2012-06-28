ENV["RACK_ENV"] = "cucumber"

require 'bundler'
Bundler.setup(:default, :cucumber)

require 'capybara/cucumber'
# require 'ruby-debug'

$LOAD_PATH << File.expand_path(File.join(
    File.dirname(__FILE__), "..", "..", "lib")) <<
              File.expand_path(File.join(
    File.dirname(__FILE__), "..", "..", "vendor", "facebook", "lib"))
require 'lovers'

Capybara.default_driver = :rack_test
Capybara.app = Lovers::Application
