module Lovers
  class Rel
    # Note: relSent are .
    RELS = "rels"    # name.split('::').last.uncapitalize.pluralize
    RECV = "reqRecv"
    SENT = "reqSent" # never shown but may show in the future

    # attr_accessor :rid, :uid, :tid # relationship_id, user_id, target_id

    def initialize(rid, uid, tid)
      @rid, @uid, @tid = rid, uid, tid
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

    def save_req
      now = Time.now.to_i
      Lovers.redis.zadd(@uid+":"+SENT, now, @rid+"|"+@tid)
      Lovers.redis.zadd(@tid+":"+RECV, now, @rid+"|"+@uid)
    end

    def save_rel
      Lovers.redis.sadd(@uid+':'+RELS, @rid+'|'+@tid) &&
      Lovers.redis.sadd(@tid+':'+RELS, @rid+'|'+@uid)
    end

    def delete

    end

    def delete_inverse
      Lovers.redis.zrem(@tid+":"+SENT, @rid+"|"+@uid)
      Lovers.redis.zrem(@uid+":"+RECV, @rid+"|"+@tid)
    end

    def rel_exists?
      Lovers.redis.sismember(@uid+':'+RELS, @rid+'|'+@tid) &&
      Lovers.redis.sismember(@tid+':'+RELS, @rid+'|'+@uid)
    end
  end
end
