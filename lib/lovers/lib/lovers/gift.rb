module Lovers
  class Gift
    RECV = "receivedGifts"
    SENT = "sentGifts"

    def initialize(gift_id, from_id, to_id)
      @gift_id, @from_id, @to_id = gift_id, from_id, to_id
    end

    def save
      Lovers.redis.zincrby(@from_id+":"+SENT, 1, @gift_id+"|"+@to_id)
      Lovers.redis.zincrby(@to_id+":"+RECV, 1, @gift_id+"|"+@from_id)
    end
  end
end
