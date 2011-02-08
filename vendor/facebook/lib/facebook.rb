require 'openssl' # decode Facebook signed_request via HMAC-SHA256
require 'json'    # parse JSON signed_request & API responses

require 'facebook/errors'
require 'facebook/user'

class Facebook
  GRAPH_DOMAIN = "graph.facebook.com"
  @@app_root = "http://apps.facebook.com"

  def self.api(path, params={}, method="GET")
    params[:method] = method
    GRAPH_DOMAIN + path
  end
  class << self; alias_method :get, :api; end # works, but is there better way?

  attr_reader :id, :secret, :canvas_page
  # http://developers.facebook.com/docs/api => App Login
  # attr_accessor :access_token # for administrative calls

  def initialize(id, secret, name)
    @id = id
    @secret = secret
    @canvas_page = "#{@@app_root}/#{name}/"
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

  def user_cookie(user_id)
    encode_data({user_id: user_id, issued_at: Time.now.to_i+86400})
  end

  protected

  def base64_url_decode(string)
    "#{string}==".tr("-_", "+/").unpack("m")[0]
  end

  def base64_url_encode(string)
    [string].pack("m").chomp("=")
  end

  def self.encode_params(params={})
    params.map { |k, v| "#{k}=#{escape v}" }.join("&")
  end

  def self.escape(string) # file cgi/util.rb, line 6
    string.gsub(/([^ a-zA-Z0-9_.-]+)/) do
      '%' + $1.unpack('H2' * $1.bytesize).join('%').upcase
    end.tr(' ', '+')
  end
end
FB = Facebook
