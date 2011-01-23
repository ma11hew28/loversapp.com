module Lovers
  class User
    attr_reader :fb_id #, :access_token, :locale, :signed_request #, etc.

    def initialize(fb_id)
      @fb_id = fb_id
      # @access_token = access_token
    end
 
    # Authenticate the user from a signed_request.
    # http://developers.facebook.com/docs/authentication/canvas
    def self.auth(signed_request)
      encoded_signature, encoded_data = signed_request.split('.')
      signature = base64_url_decode(encoded_signature)
      expected_signature = OpenSSL::HMAC.digest('sha256', Lovers::Conf.fb_app_secret, encoded_data)
      if signature == expected_signature
        signed_request = JSON.parse base64_url_decode(encoded_data)
        User.new(signed_request["user_id"]).tap { |u| u.add_app_user }
      else raise end
    rescue
      raise AuthenticationError
    end

    def add_app_user
      Lovers.redis.sadd("appUsrs", fb_id)
      Lovers.redis.srem("oldUsrs", fb_id)
    end

    def rem_app_user
      Lovers.redis.srem("appUsrs", fb_id)
      Lovers.redis.sadd("oldUsrs", fb_id)
    end

    def send_req(rid, tid)
      rel = Rel.new(rid, fb_id, tid)

      # If inverse request exists, delete it and confirm relationship.
      return rel.add_rel ? "2" : "3" if rel.rem_req_inv || rel.rem_hid_inv

      return "3" if rel.rel_exists?

      rel.add_req ? "1" : "0"
    end

    def conf_req(rid, uid)
      rel = Rel.new(rid, uid, fb_id)

      return rel.add_rel ? "1" : "2" if rel.rem_req || rel.rem_hid

      return rel.rel_exists? ? "0" : "2"
    end

    def hide_req(rid, uid)
      rel = Rel.new(rid, uid, fb_id)

      return rel.add_hid ? "1" : "0" if rel.rem_req

      return rel.hid_exists? ? "0" : (rel.rel_exists? ? "3" : "2")
    end

    def remv_req(rid, uid)
      rel = Rel.new(rid, uid, fb_id)

      return (rel.rem_req || rel.rem_hid) ? "1" : "0"
    end

    def remv_rel(rid, uid)
      rel = Rel.new(rid, uid, fb_id)

      return rel.rem_rel ? "1" : "0"
    end

    def reqs
      {:sent => reqs_sent, :hidn => reqs_hidn}
    end

    def reqs_sent
      Lovers.redis.zrange(fb_id+':'+Rel::SENT, 0, -1)
    end

    def reqs_recv
      Lovers.redis.zrange(fb_id+':'+Rel::RECV, 0, -1)
    end

    def reqs_hidn
      Lovers.redis.zrange(fb_id+':'+Rel::HIDN, 0, -1)
    end

    def rels
      Lovers.redis.smembers(fb_id+':'+Rel::RELS)
    end

    private

    # This should be a method of another class. Maybe a Util class.
    # https://github.com/ptarjan/base64url/blob/master/ruby.rb
    def self.base64_url_decode(str)
      str += '=' * (4 - (short = str.size.modulo(4))) unless short == 0
      Base64.decode64(str.tr('-_', '+/'))
    end
  end
end
