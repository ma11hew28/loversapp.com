class Facebook
  # http://developers.facebook.com/docs/creditsapi
  class Product

    # KISS: Just simple assignment. Leave the validations up to Facebook.
    def initialize(options={})
      @item_id = options[:item_id] # specific identifier, not used by Facebook
      @title = options[:title] # <= 50 characters
      @description = options[:description] # <= 175 characters
      @image_url = options[:image_url]
      @product_url = options[:product_url] # permalink to where you show product
      @price = options[:image_url] # > 0 credits
      @data = options[:data] # optional, stored & sent back with order_details
    end
  end
end

# def validate_length!(name="", value, op, length)
#   if string.length > length
#     raise ArgumentError "#{name} must be #{op} #{length} characters"
#   end
# end
