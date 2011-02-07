module Facebook
  class Application
    ROOT_URL = "http://apps.facebook.com"

    attr_reader :id, :secret, :canvas_page
    # http://developers.facebook.com/docs/api => App Login
    # attr_accessor :access_token # for administrative calls. YAGNI

    def initialize(id, secret, name)
      @id = id
      @secret = secret
      @canvas_page = "#{ROOT_URL}/#{name}/"
      Facebook.application = self
    end

    # Facebook sends a signed_requests to authenticate certain requests.
    # http://developers.facebook.com/docs/authentication/signed_request/
    def decode_signed_request!(signed_request)
      encoded_signature, encoded_data = signed_request.split('.')
      signature = base64_url_decode(encoded_signature)
      expected_signature = OpenSSL::HMAC.digest('sha256', @secret, encoded_data)
      if signature == expected_signature
        JSON.parse base64_url_decode(encoded_data)
      else
        raise AuthenticationError.new "signature: '#{signature}' != expected_signature: '#{expected_signature}'"
      end
    rescue StandardError => e
      raise AuthenticationError.new "signed_request: '#{signed_request}' - #{e.inspect}"
    end

    def encode_data(data)
      encoded_data      = base64_url_encode(data.to_json)
      encoded_signature = base64_url_encode(
        OpenSSL::HMAC.digest('sha256', @secret, encoded_data))
      "#{encoded_signature}.#{encoded_data}"
    end

    protected

    def base64_url_decode(string)
      "#{string}==".tr("-_", "+/").unpack("m")[0]
    end

    def base64_url_encode(string)
      [string].pack("m").chomp("=")
    end
  end
end
