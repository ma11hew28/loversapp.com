ENV["RACK_ENV"] = "cucumber"

require 'ruby-debug'
require 'rspec-expectations'

$LOAD_PATH << File.expand_path("../../../lib", __FILE__)
$LOAD_PATH << File.expand_path("..", __FILE__)

require 'lovers'

require 'redis_test_setup'
RedisTestSetup.start_redis!(:cucumber)
