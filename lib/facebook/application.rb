module Facebook
  class Application
    attr_reader :app_id, :app_secret
    def initialize(app_id, app_secret)
      @app_id = app_id
      @app_secret = app_secret
    end

    # Decode signed_request Facebook sends
    def auth!(signed_request)
      encoded_signature, encoded_data = signed_request.split('.')
      signature = base64_url_decode(encoded_signature)
      expected_signature = OpenSSL::HMAC.digest('sha256', @app_secret, encoded_data)
      if signature == expected_signature
        JSON.parse base64_url_decode(encoded_data)
      else
        raise AuthenticationError.new "signature: #{signature} != expected_signature: #{expected_signature}"
      end
    rescue StandardError => e
      raise AuthenticationError.new "signed_request: #{signed_request} - #{e.inspect}"
    end

    protected

    def base64_url_decode(string)
      "#{string}==".tr("-_", "+/").unpack("m")[0]
    end
  end
end
