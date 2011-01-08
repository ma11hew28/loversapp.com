###############################################################################
# Configure ###################################################################
###############################################################################

require './conf.rb' # set Facebook constants, etc.
require 'erb'       # use Erb templates

configure :development do
  require 'ruby-debug'
  REDIS = Redis.new
end

configure :production do
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

before { content_type 'application/json' }


###############################################################################
# Models ######################################################################
###############################################################################

class Facebook
  attr_accessor :user_id, :access_token, :signed_request

  # http://developers.facebook.com/docs/authentication/canvas
  # Initialize the user state from a signed_request.
  def initialize(signed_request)
    return if signed_request.nil?
    encoded_signature, encoded_data = signed_request.split('.')
    signature = base64_url_decode(encoded_signature)
    expected_signature = HMAC::SHA256.digest(FB_APP_SECRET, encoded_data)
    if signature == expected_signature
      self.signed_request = JSON.parse base64_url_decode(encoded_data)
      self.user_id = self.signed_request["user_id"]
      self.access_token = self.signed_request["oauth_token"]
    end
  end
end

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
  # Validate that uid, tid, rel are integers and rel is btw 0 to NUM_RELS.
  uid, tid, rel = params[:uid], params[:tid], params[:rel] # get uid from FB
  return PERR unless valid_rel?(rel)
  return PERR unless (Integer(uid) && Integer(tid) rescue false)

  # If my friend already made this request, confirm it.

  # If this relation already exists, return w/ feedback code.

  # Add the request.
  now = Time.now.to_i
  REDIS.zadd(uid+':reqSent', now, rel+'|'+tid) # not shown but may in future
  REDIS.zadd(tid+':reqRecv', now, rel+'|'+uid) ? "1" : "0"
end

# DELETE (ignore) a request.
delete '/fb/canvas/reqs' do
  # Validate that uid, tid, rel are integers and rel is btw 0 to NUM_RELS.
  uid, tid, rel = params[:uid], params[:tid], params[:rel] # get uid from FB
  return PERR unless valid_rel?(rel)
  return PERR unless (Integer(uid) && Integer(tid) rescue false)

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
  return PERR unless (Integer(uid) && Integer(tid) rescue false)

  # Remove the request, and add the relationship.
  REDIS.zrem(tid+':reqSent', rel+'|'+uid) # not shown but may in future
  if REDIS.zrem(uid+':reqRecv', rel+'|'+tid)
    REDIS.sadd(uid+':rels', rel+'|'+tid) ||
    REDIS.sadd(tid+':rels', rel+'|'+uid) ? "1" : "0"
  else "o" end # no request
end

# DELETE (break up) a relationship.
delete '/fb/canvas/rels' do
  # Validate that uid, tid, rel are integers and rel is btw 0 to NUM_RELS.
  uid, tid, rel = params[:uid], params[:tid], params[:rel] # get uid from FB
  return PERR unless valid_rel?(rel)
  return PERR unless (Integer(uid) && Integer(tid) rescue false)

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

# https://github.com/ptarjan/base64url/blob/master/ruby.rb
def base64_url_decode(str)
  str += '=' * (4 - (short = str.size.modulo(4))) unless short == 0
  Base64.decode64(str.tr('-_', '+/'))
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
