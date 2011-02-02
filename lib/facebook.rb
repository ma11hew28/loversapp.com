require 'openssl' # decode Facebook signed_request via HMAC-SHA256
require 'json'    # parse JSON signed_request

require 'facebook/errors'
require 'facebook/application'

module Facebook
end
FB = Facebook
