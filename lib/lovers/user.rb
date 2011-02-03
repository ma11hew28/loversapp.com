module Lovers
  class User
    attr_reader :fb_id #, :locale, :signed_request #, etc.
    attr_accessor :access_token

    def initialize(fb_id)
      Integer(@fb_id = fb_id) rescue raise NonAppUser.new "fb_id: "+fb_id
    end
 
    # Authenticate the user from a signed_request.
    # http://developers.facebook.com/docs/authentication/canvas
    def self.auth!(signed_request)
      request = Lovers.fb.auth!(signed_request)
      User.new(request["user_id"]).tap do |u|
        u.add_app_user
        u.access_token = request["oauth_token"]
      end
    rescue Facebook::AuthenticationError => e
      raise AuthenticationError.new e.message
    end

    def self.auth(*args)
      auth!(*args)
    rescue AuthenticationError => e
      Lovers.logger.error e.inspect
      nil
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

      return "3" if rel.rel_exact?

      rel.add_req ? "1" : "0"
    end

    def send_gift(gid, tid)
      Gift.new(gid, fb_id, tid).add ? "1" : "0"
    end

    def conf_req(rid, uid)
      rel = Rel.new(rid, uid, fb_id)

      return rel.add_rel ? "1" : "0" if rel.rem_req || rel.rem_hid

      return rel.rel_exists? ? "0" : "2"
    end

    def hide_req(rid, uid)
      rel = Rel.new(rid, uid, fb_id)

      return rel.add_hid ? "1" : "0" if rel.rem_req

      return rel.hid_exists? ? "0" : (rel.rel_exists? ? "3" : "2")
      
      # return rel.hide ? "1" : "0"
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
      Lovers.redis.zrange(fb_id+':'+Rel::RELS, 0, -1)
    end

    def gifts_sent
      Lovers.redis.zrange(fb_id+':'+Gift::SENT, 0, -1, :with_scores => true)
    end

    def gifts_recv
      Lovers.redis.zrange(fb_id+':'+Gift::RECV, 0, -1, :with_scores => true)
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
