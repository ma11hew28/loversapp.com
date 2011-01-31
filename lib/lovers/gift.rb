module Lovers
  class Gift
    RECV = "gftRecv"
    SENT = "gftSent"

    def initialize(gid, uid, tid)
      @gid, @uid, @tid = gid, uid, tid
      @gp, @uc, @tc = @gid+"|", @uid+":", @tid+":"
      @gpu, @gpt = @gp+@uid, @gp+@tid
    end

    def add
      Lovers.redis.zincrby(@uc+SENT, 1, @gpt)
      Lovers.redis.zincrby(@tc+RECV, 1, @gpu)
    end
  end
end
