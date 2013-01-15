require 'sinatra'

configure do
  # set :protection, :origin_whitelist => ['https://apps.facebook.com']
  disable :protection
end

# Initial Facebook request comes in as a POST with a signed_request.
post "/facebook/ " do
  erb :index
end

post "/facebook/privacy" do
  erb :privacy
end
