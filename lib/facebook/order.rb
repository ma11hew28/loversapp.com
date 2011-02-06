module Facebook
  class Order
    def initialize(order_id)
      @order_id = order_id
    end

    def save
      Lovers.redis.zincrby(@uc+SENT, 1, @gpt)
      Lovers.redis.zincrby(@tc+RECV, 1, @gpu)
    end

    def all
      Lovers.redis.
    end
  end
end
