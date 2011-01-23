ENV["RACK_ENV"] = "cucumber"

require 'ruby-debug'
require 'rspec-expectations'

$LOAD_PATH << File.expand_path("../../../lib", __FILE__)
$LOAD_PATH << File.expand_path("..", __FILE__)

require 'lovers'

module Lovers
  module Test
    URL = "http://localhost:9393/fb/canvas/"

    # example signed_request Facebook sends via POST request to FB_CANVAS_URL
    SIGNED_REQUEST = "FG1uGHoaGeNH2lxcfJG8AU1MBosRPTf_Wf6R5HQo-2Y.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEyOTQ1MTY4MDAsImlzc3VlZF9hdCI6MTI5NDUxMjQ3Miwib2F1dGhfdG9rZW4iOiIxMjAwMjc3NDU0MzB8Mi5FS1NJd2FOZ21GN1c3aF9pTV9BM2Z3X18uMzYwMC4xMjk0NTE2ODAwLTUxNDQxN3xHV3dUT3FzWnI1S1pSUTBwVWFEMVB3MjhZSDgiLCJ1c2VyIjp7ImxvY2FsZSI6ImVuX1VTIiwiY291bnRyeSI6InVzIn0sInVzZXJfaWQiOiI1MTQ0MTcifQ"

    # example cookie generated from signed_request above
    COOKIE = ""
  end
end

require 'redis_test_setup'
RedisTestSetup.start_redis!(:cucumber)
