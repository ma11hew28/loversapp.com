module Lovers
  class User
    attr_reader :facebook # account
    # attr_reader :twitter # TODO: tweet love

    def initialize(facebook_user_id, facebook_access_token=nil)
      @facebook = Facebook::User.new(facebook_user_id, facebook_access_token)
    end

    # Authenticate the user from a signed_request.
    # http://developers.facebook.com/docs/authentication/canvas
    def self.auth!(signed_request)
      request = Lovers.facebook.decode_signed_request(signed_request)
      User.create!(request["user_id"], request["oauth_token"])
    rescue Facebook::AuthenticationError => e
      raise AuthenticationError.new e.message
    end

    def self.auth(*args)
      auth!(*args)
    rescue AuthenticationError => e
      Lovers.logger.error e.inspect
      nil
    end

    def self.create!(*args)
      User.new(*args).tap { |u| u.save }
    end

    def save
      Lovers.redis.sadd("users", facebook.user_id)
      Lovers.redis.srem("Users", facebook.user_id)
    end

    def delete
      Lovers.redis.srem("users", facebook.user_id)
      Lovers.redis.sadd("alums", facebook.user_id)
    end

    def send_gift(gift_id, to_id)
      Gift.new(gift_id, facebook.user_id, to_id).save ? "1" : "0"
    end

    # http://developers.facebook.com/docs/reference/dialogs/requests/
    def accept_requests(request_ids)
      request_ids = request_ids.split "," # TODO: move to application

      requests.find_all { |r| request_ids.delete r["id"] }

      requests.each do |r|
        Relationship.create(r["data"], r["from"]["id"], facebook.user_id)
      end

      request_ids # not found
    end

    def remove_relationship(relationship_id, user_id)
      rel = Relationship.new(relationship_id, user_id, facebook.user_id)
      return rel.delete ? "1" : "0"
    end

    def requests
      @requests ||= get("apprequests")
    end

    def relationships
      Lovers.redis.zrange(facebook.user_id+':'+Relationship::RELS, 0, -1)
    end

    def sent_gifts
      Lovers.redis.zrange(facebook.user_id+':'+Gift::SENT, 0, -1, with_scores: true)
    end

    def received_gifts
      Lovers.redis.zrange(facebook.user_id+':'+Gift::RECV, 0, -1, with_scores: true)
    end
  end
end
