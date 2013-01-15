require 'sinatra'

# Initial Facebook request comes in as a POST with a signed_request.
post "/facebook/ " do
  erb :index
end

post "/facebook/privacy" do
  erb :privacy
end
