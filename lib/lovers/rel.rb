module Lovers
  class Rel
    # Note: relSent are .
    RELS = "rels"    # name.split('::').last.uncapitalize.pluralize
    RECV = "reqRecv"
    SENT = "reqSent" # never shown but may show in the future
    HIDN = "reqHidn"

    # attr_accessor :rid, :uid, :tid # relationship_id, user_id, target_id

    def initialize(rid, uid, tid)
      @rid, @uid, @tid = rid, uid, tid
      @rp, @uc, @tc = @rid+"|", @uid+":", @tid+":"
      @rpu, @rpt = @rp+@uid, @rp+@tid
    end

    # def reverse
    #   temp = @tid
    #   @tid = @uid
    #   @uid = temp
    #   self
    # end

    # def self.create_rel(rid, uid, tid)
    #   self.new(rid, uid, tid).tap { |r| r.save_rel }
    # end

    # def self.create_req(rid, uid, tid)
    #   self.new(rid, uid, tid).tap { |r| r.save_rel }
    # end

    def add_req
      now = Time.now.to_i
      Lovers.redis.zadd(@uc+SENT, now, @rid+"|"+@tid)
      Lovers.redis.zadd(@tc+RECV, now, @rid+"|"+@uid)
    end

    def add_hid
      Lovers.redis.zadd(@tc+HIDN, Time.now.to_i, @rid+"|"+@uid)
    end

    def add_rel
      Lovers.redis.sadd(@uc+RELS, @rpt) &&
      Lovers.redis.sadd(@tc+RELS, @rpu)
    end

    def rem_req
      Lovers.redis.zrem(@uc+SENT, @rpt)
      Lovers.redis.zrem(@tc+RECV, @rpu)
    end

    def rem_req_inv # remove inverse request
      Lovers.redis.zrem(@tc+SENT, @rpu)
      Lovers.redis.zrem(@uc+RECV, @rpt)
    end

    def rem_hid
      Lovers.redis.zrem(@tc+HIDN, @rpu)
    end

    def rem_hid_inv # remove inverse request if true
      Lovers.redis.zrem(@uc+HIDN, @rpt)
    end

    def rem_rel
      Lovers.redis.srem(@uc+RELS, @rpt) &&
      Lovers.redis.srem(@tc+RELS, @rpu)
    end

    def rel_exists?
      Lovers.redis.sismember(@uc+RELS, @rpt) &&
      Lovers.redis.sismember(@tc+RELS, @rpu)
    end

    def hid_exists?
      !!Lovers.redis.zrank(@tc+HIDN, @rpu)
    end
  end
end
