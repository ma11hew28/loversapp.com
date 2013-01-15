require 'sinatra'

configure do
  # set :protection, :origin_whitelist => ['https://apps.facebook.com']
  disable :protection
end

# Initial Facebook request comes in as a POST with a signed_request.
post '/facebook/' do
  erb :'facebook/index'
end

get '/facebook/privacy' do
  erb :'facebook/privacy'
end

# get '/' do
#   logger.info env
#   # "hello"
#   erb :'facebook/index'
# end
