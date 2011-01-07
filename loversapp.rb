configure :development do
  require 'ruby-debug'
  REDIS = Redis.new
end

configure :production do
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

get '/' do
  'Hello world!'
end

get '/fb/canvas/' do
  erb :main
end

REL = {
  :"0" => "Relationship",
  :"1" => "Engagement",
  :"2" => "Marriage",
  :"3" => "It's Complicated",
  :"4" => "Open Relationship",
  :"5" => "Valentine"
}
NUM_RELS = REL.size

# Return all requests for a user.
# How can we store these requests using Facebook's request system?
get '/fb/canvas/reqs' do
  # Validate that uid is an integer.
  uid = params[:uid] || "2"; # get this from session
  return 0 unless (Integer(uid) rescue false)
  REDIS.zrange(uid+':reqsRecv', 0, -1).inspect
end

# Add a request from one user (uid) to another (tid)
post '/fb/canvas/reqs' do
  error = "0"

  # Validate relationship type.
  rel = Integer(params[:rel]) rescue false
  return error unless NUM_RELS > rel && rel > 0
  rel = rel.to_s

  # Validate that uid & tid are integers.
  # TODO, get uid from FB auth.
  uid = params[:uid]; tid = params[:tid]
  return error unless (Integer(uid) && Integer(tid) rescue false)

  # Add the request.
  now = Time.now.to_i
  REDIS.zadd(uid+':reqsSent', now, rel+'|'+tid) # not shown but may in future
  REDIS.zadd(tid+':reqsRecv', now, rel+'|'+uid)
end

# Ignore (delete) a request.
delete '/fb/canvas/reqs' do
  error = "0"

  # Validate relationship type.
  rel = Integer(params[:rel]) rescue false
  return error unless NUM_RELS > rel && rel > 0
  rel = rel.to_s

  # Validate that uid & tid are integers.
  # TODO, get uid from FB auth.
  uid = params[:uid]; tid = params[:tid]
  return error unless (Integer(uid) && Integer(tid) rescue false)

  # Remove the request.
  REDIS.zrem(uid+':reqsSent', rel+'|'+tid) # not shown but may in future
  REDIS.zrem(tid+':reqsRecv', rel+'|'+uid)
end

# Cool projects
# mechanical turk
# patch
# locomotive
# omniauth
# mjording
# nyc-ruby-meetup

# Specs: It should:
# Redis

# Facebook Stream API
# - Show all my friends posts
# - Show all posts
#

# Questions
# What is O(N) for SCARD? Is it better to store the CARD so that it's O(1)?
