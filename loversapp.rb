###############################################################################
# Configure ###################################################################
###############################################################################

require './conf.rb' # set Facebook constants, etc.
require 'erb'       # use Erb templates

configure :development do
  require 'ruby-debug'
end

before { content_type 'application/json' }


###############################################################################
# Models ######################################################################
###############################################################################

get '/' do
  content_type 'text/html'
  "Hello world!"
end


###############################################################################
# Canvas ######################################################################
###############################################################################

# GET (serve) the Facebook app's canvas page.
get '/fb/canvas/' do
  content_type 'text/html'
  cache_control :public, :max_age => 31536000 # seconds (1 year)
  erb :main
end

# Initial Facebook request comes in as a POST with a signed_request.
post '/fb/canvas/' do
  content_type 'text/html'
  fb = Facebook.new(params[:signed_request])
  uid = fb.user_id
  @user = {
    :reqs => REDIS.zrange(uid+':reqRecv', 0, -1),
    :rels => REDIS.smembers(uid+':rels')
  }
  erb :main
end

###############################################################################
# Share #######################################################################
###############################################################################
# Facebook Stream API
# - Show all my friends posts
# - Show all posts


###############################################################################
# Requests ####################################################################
###############################################################################
# How can we manage requests on Facebook? If we can set a type for each sent
# request and get & delete them, then we could replace this request code.
#
# Each user has two Redis ordered sets (`reqSent` & `reqRecv`) that store uids.
# The SCORE that we order the requests by is `time` (UNIX timestamp).
# The request id (rid) is encoded as a number and prepended to the uid. rid|uid
# E.g., for the user with uid=100, we might have:
#   100:reqSent => ["1|123", "2|123", "2|134"]  # format: ["rid|tid"]
#   100:reqRecv => ["3|343", "5|142", "4|2224"] # format: ["rid|uid"]

REL = {
  :"0" => "Relationship",
  :"1" => "Engagement",
  :"2" => "Marriage",
  :"3" => "It's Complicated",
  :"4" => "Open Relationship",
  :"5" => "Valentine"
}
NUM_RELS = REL.size

# GET (show) all requests for a user.
get '/fb/canvas/reqs' do
  # Validate that uid is an integer.
  uid = params[:uid] || "1" # get uid from FB
  return PERR unless (Integer(uid) rescue false)
  REDIS.zrange(uid+':reqRecv', 0, -1).inspect
end

# POST (add) a request from one user (uid) to another (tid)
post '/fb/canvas/reqs' do
  # fb.user.request(validate_params(params[:rel], params[:tid]))

  # Validate that uid, tid, rel are integers and rel is btw 0 to NUM_RELS.
  uid, tid, rel = params[:uid], params[:tid], params[:rel] # get uid from FB
  return PERR unless valid_rel?(rel)
  return PERR unless (Integer(uid) && Integer(tid) && uid != tid rescue false)

  # If target already made this request, remove it and confirm relationship.
  urel, trel = rel+'|'+uid, rel+'|'+tid
  REDIS.zrem(tid+':reqSent', urel) # not shown but may in future
  if REDIS.zrem(uid+':reqRecv', trel)
    return REDIS.sadd(uid+':rels', trel) && REDIS.sadd(tid+':rels', urel) ?
        "q" : "l"
  end

  # If this relation already exists, return w/ feedback code.
  if REDIS.sismember(uid+':rels', trel) && REDIS.sismember(tid+':rels', urel)
    return "l"

  # Add the request.
  now = Time.now.to_i
  REDIS.zadd(uid+':reqSent', now, trel) # not shown but may in future
  REDIS.zadd(tid+':reqRecv', now, urel) ? "1" : "0"
end

# DELETE (ignore) a request.
delete '/fb/canvas/reqs' do
  # Validate that uid, tid, rel are integers and rel is btw 0 to NUM_RELS.
  uid, tid, rel = params[:uid], params[:tid], params[:rel] # get uid from FB
  return PERR unless valid_rel?(rel)
  return PERR unless (Integer(uid) && Integer(tid) && uid != tid rescue false)

  # Remove the request.
  REDIS.zrem(tid+':reqSent', rel+'|'+uid) # not shown but may in future
  REDIS.zrem(uid+':reqRecv', rel+'|'+tid) ? "1" : "0"
end


###############################################################################
# Relationships ###############################################################
###############################################################################

# GET (show) all relationships for a user.
get '/fb/canvas/rels' do
  # Validate that uid is an integer.
  uid = params[:uid] || "2"; # get this from session
  return PERR unless (Integer(uid) rescue false)
  REDIS.smembers(uid+':rels').inspect
end

# POST (confirm/add) a relationship between two users.
post '/fb/canvas/rels' do
  # Validate that uid, tid, rel are integers and rel is btw 0 to NUM_RELS.
  uid, tid, rel = params[:uid], params[:tid], params[:rel] # get uid from FB
  return PERR unless valid_rel?(rel)
  return PERR unless (Integer(uid) && Integer(tid) && uid != tid rescue false)

  # Remove the request, and add the relationship.
  urel, trel = rel+'|'+uid, rel+'|'+tid
  REDIS.zrem(tid+':reqSent', urel) # not shown but may in future
  if REDIS.zrem(uid+':reqRecv', trel)
    REDIS.sadd(uid+':rels', trel) && REDIS.sadd(tid+':rels', urel) ? "1" : "0"
  else "o" end # no request
end

# DELETE (break up) a relationship.
delete '/fb/canvas/rels' do
  # Validate that uid, tid, rel are integers and rel is btw 0 to NUM_RELS.
  uid, tid, rel = params[:uid], params[:tid], params[:rel] # get uid from FB
  return PERR unless valid_rel?(rel)
  return PERR unless (Integer(uid) && Integer(tid) && uid != tid rescue false)

  # Remove the relationship.
  REDIS.srem(uid+':rels', rel+'|'+tid) ||
  REDIS.srem(tid+':rels', rel+'|'+uid) ? "1" : "0"
end


###############################################################################
# Utility Methods #############################################################
###############################################################################

def valid_rel?(rel)
  rel = Integer(rel) rescue (return false)
  return NUM_RELS > rel && rel > 0
end

def valid_int?(str)
  Integer(uid)
end

# @staticmethod
# def base64_url_encode(data):
#     return base64.urlsafe_b64encode(data).rstrip('=')


# Cool projects
# mechanical turk
# patch
# locomotive
# omniauth
# mjording
# nyc-ruby-meetup

# Specs: It should:
# Redis

# Questions
