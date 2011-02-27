$LOAD_PATH << File.expand_path(File.join(
    File.dirname(__FILE__), "..", "vendor", "facebook", "lib"))
require 'lovers'

RSpec.configure do |config|
  config.before(:each) do
    Lovers.redis.flushdb
  end
end
