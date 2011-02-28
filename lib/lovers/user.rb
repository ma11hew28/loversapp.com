class Array
  def sum_odds
    sum = 0; each_with_index { |s, i| sum += Integer(s) if i.odd? }; sum
  end

  def sum_points
    sum = 0
    each_slice(2) do |gid_tid, score|
      sum += Lovers::Gift.new(gid_tid.split("|").first).points * score.to_i
    end
    sum
  end
end

module Lovers
  class User
    @@admin_uids = Conf.admin_uids; def self.admins; @@admin_uids; end

    attr_reader :facebook # account
    # attr_reader :twitter # TODO: tweet love

    def initialize(facebook_user_id=nil, facebook_access_token=nil)
      if facebook_user_id
        @facebook = Facebook::User.new(facebook_user_id, facebook_access_token)
      end
    rescue ArgumentError => e
      Lovers.logger.error e.inspect # suspicious facebook_user_id
    end

    # Authenticate the user from a signed_request.
    # http://developers.facebook.com/docs/authentication/canvas
    def self.auth!(signed_request)
      request = Lovers.facebook.decode_signed_request(signed_request)
      User.create(request["user_id"], request["oauth_token"])
    rescue Facebook::AuthenticationError => e
      raise AuthenticationError.new e.message
    end

    def self.auth(signed_request)
      auth!(signed_request)
    rescue AuthenticationError => e
      Lovers.logger.error e.inspect
      User.new
    end

    def self.create(*args)
      User.new(*args).tap { |u| u.save unless u.facebook.nil? }
    end

    def self.count
      Lovers.redis.scard("users")
    end

    def self.all
      Lovers.redis.smembers("users") # don't memoize, dynamic across requests
    end

    def self.alums
      Lovers.redis.smembers("alums")
    end

    def self.top_lovers
      Lovers.redis.zrevrange("points", 0, 9, with_scores: true)
    end

    def self.most_loving
      Lovers.redis.zrevrange("proactivePoints", 0, 9, with_scores: true)
    end

    def self.most_loved
      Lovers.redis.zrevrange("attractedPoints", 0, 9, with_scores: true)
    end

    def self.paginate(options={})
      per_page = options[:per_page] || 20
      offset = [(options[:page] || 1) - 1, 0].max * per_page
      Lovers.redis.sort("users", :limit => [offset, per_page])
    end

    def admin?
      facebook && @@admin_uids.include?(facebook.id)
    end

    def save
      Lovers.redis.multi
      Lovers.redis.sadd("users", facebook.id)
      Lovers.redis.srem("alums", facebook.id)
      Lovers.redis.exec
    end

    def delete
      Lovers.redis.multi
      Lovers.redis.srem("users", facebook.id)
      Lovers.redis.sadd("alums", facebook.id)
      Lovers.redis.exec
    end

    # Returns number of times this same gift has been sent.
    def send_gift(gift_id, to_id)
      gift = Gift.new(gift_id, facebook.id, to_id)
      Lovers.redis.multi
      gift.send
      gift.award_points
      Lovers.redis.exec
    end

    # http://developers.facebook.com/docs/reference/dialogs/requests/
    def accept_requests(request_ids)
      request_ids = request_ids.split "," # TODO: move to application

      requests.find_all { |r| request_ids.delete r["id"] }

      requests.each do |r|
        Relationship.create(r["data"], r["from"]["id"], facebook.id)
      end

      request_ids # not found
    end

    def remove_relationship(relationship_id, user_id)
      rel = Relationship.new(relationship_id, user_id, facebook.id)
      return rel.delete ? "1" : "0"
    end

    def relationships
      Lovers.redis.zrange("#{facebook.id}:#{Relationship::RELS}", 0, -1)
    end

    def sent_gifts
      Lovers.redis.zrange("#{facebook.id}:#{Gift::SENT}", 0, -1, with_scores: true)
    end

    def sent_gifts_count
      sent_gifts.sum_odds
    end

    def received_gifts
      Lovers.redis.zrange("#{facebook.id}:#{Gift::RECV}", 0, -1, with_scores: true)
    end

    def received_gifts_count
      received_gifts.sum_odds
    end

    def self.calculate_points_once
      return unless new(User.admins[1]).points.zero?
      User.all.map do |i|
        User.new(i).tap do |u|
          u.calculate_points
          u.save_points
        end
      end
    end

    def points
      @points ||= \
        Integer(Lovers.redis.zscore("points", facebook.id) || "0")
    end

    def proactive_points
      @praactive_points ||= \
        Integer(Lovers.redis.zscore("proactivePoints", facebook.id) || "0")
    end

    def attracted_points
      @attracted_points ||= \
        Integer(Lovers.redis.zscore("attractedPoints", facebook.id) || "0")
    end

    def calculate_points
      @points = calculate_proactive_points + calculate_attracted_points
    end

    def calculate_proactive_points
      @proactive_points = sent_gifts.sum_points
    end

    def calculate_attracted_points
      @attracted_points = received_gifts.sum_points
    end

    def save_points
      unless @points.zero?
        Lovers.redis.zadd("points", @points, facebook.id)
        save_proactive_points
        save_attracted_points
      end
    end

    def save_proactive_points
      Lovers.redis.zadd("proactivePoints", @proactive_points, facebook.id)
    end

    def save_attracted_points
      Lovers.redis.zadd("attractedPoints", @attracted_points, facebook.id)
    end
  end
end
