module Facebook
  # http://developers.facebook.com/docs/creditsapi
  class Order
    def initialize(order_id)
      @order_id = order_id
    end

    # GET https://graph.facebook.com/[app id]/payments?status=STATUS&since=SINCE&until=UNTIL&access_token=ACCESS_TOKEN
    def find

    end

    def save

    end

    def all

    end
  end
end
