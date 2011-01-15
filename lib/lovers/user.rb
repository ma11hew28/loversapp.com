module Lovers
  class User
    attr_reader :fb_id, :access_token #, :locale, :signed_request, etc.
    attr_accessor :sent_reqs, :recv_reqs, :hidn_reqs

    def initialize
      self.sent_reqs = []
      self.recv_reqs = []
      self.hidn_reqs = []
    end

    # http://developers.facebook.com/docs/authentication/canvas
    # Initialize the user state from a signed_request.
    def login(signed_request)
      return if signed_request.nil?
      encoded_signature, encoded_data = signed_request.split('.')
      signature = base64_url_decode(encoded_signature)
      expected_signature = HMAC::SHA256.digest(FB_APP_SECRET, encoded_data)
      if signature == expected_signature
        signed_request = JSON.parse base64_url_decode(encoded_data)
        @fb_id = signed_request["user_id"]
        @access_token = signed_request["oauth_token"]
      end
    end

    def send_request(rid, uid)

      # sent_reqs << Request.new(rid, uid)
    end

    private

    # This should be a method of another class. Maybe a Util class.
    # https://github.com/ptarjan/base64url/blob/master/ruby.rb
    def base64_url_decode(str)
      str += '=' * (4 - (short = str.size.modulo(4))) unless short == 0
      Base64.decode64(str.tr('-_', '+/'))
    end
  end
end
