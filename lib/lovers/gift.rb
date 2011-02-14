module Lovers
  class Gift
    RECV = "receivedGifts"
    SENT = "sentGifts"

    # cool fb gifts
    # 10: rose
    # 13: panties
    # 16: heart cookie w love written on it with icing
    # 1000: call me candy heart
    # 10 credits = $1
    GIFTS = [
      { # 0 # cannot be sold through FB credits because it's free
        title: "Red Heart",
        description: "Happy Valentine's Day!",
        price: 0,
        image_url: "#{Lovers.host}/images/gifts/red-heart.png",
        product_url: "#{Lovers.host}/images/gifts/red-heart.png"
        # data: 3 # optional; stored on FB & included in order_details
      },
      { # 1
        title: "Red Rose",
        description: "Happy Valentine's Day!",
        price: 10,
        image_url: "#{Lovers.host}/images/gifts/red-rose.png",
        product_url: "#{Lovers.host}/images/gifts/red-rose.png"
      },
      { # 2
        title: "One-Dozen Red Roses",
        description: "Happy Valentine's Day!",
        price: 99,
        image_url: "#{Lovers.host}/images/gifts/dozen-red-roses.png",
        product_url: "#{Lovers.host}/images/gifts/dozen-red-roses.png"
      },
      { # 3
        title: "Blue Diamond",
        description: "Happy Valentine's Day!",
        price: 3304,
        image_url: "#{Lovers.host}/images/gifts/blue-diamond.png",
        product_url: "#{Lovers.host}/images/gifts/blue-diamond.png"
      }
    ]

    def self.find(id)
      GIFTS[Integer(id)] # raises TypeError unless id is an Integer
    end

    def initialize(id, from_id, to_id)
      @id, @from_id, @to_id = id, from_id, to_id
    end

    def save
      Lovers.redis.zincrby("#{@from_id}:#{SENT}", 1, "#{@id}|#{@to_id}")
      Lovers.redis.zincrby("#{@to_id}:#{RECV}", 1, "#{@id}|#{@from_id}")
    end
  end
end
