require 'net/http'  # make public & secure requests to Facebook Graph API
require 'net/https' # decode Facebook signed_request via HMAC-SHA256
require 'json'      # parse JSON signed_request & API responses

require 'facebook/errors'
require 'facebook/user'

class Facebook
  GRAPH_DOMAIN = "graph.facebook.com"
  @@app_root = "https://apps.facebook.com"

  def self.api(path, params={}, method="GET")
    path += "?#{encode_params(params)}" unless params.empty?
    JSON.parse((params[:access_token] ? https : http).get(path).body)["data"]
  end
  class << self; alias_method :get, :api; end # works, but is there better way?

  def self.http
    @http ||= Net::HTTP.new(GRAPH_DOMAIN)
  end

  def self.https
    @https ||= Net::HTTP.new(GRAPH_DOMAIN, 443).tap do |h|
      h.use_ssl = true
      # we turn off certificate validation to avoid the "warning: peer
      # certificate won't be verified in this SSL session" warning not sure if
      # this is the right way to handle it see
      # http://redcorundum.blogspot.com/2008/03/ssl-certificates-and-nethttps.html
      h.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end

  attr_reader :id, :canvas_page, :canvas_url
  # http://developers.facebook.com/docs/api => App Login
  # attr_accessor :access_token # for administrative calls

  def initialize(options={})
    @id = options[:id]
    @secret = options[:secret]
    @canvas_page = "#{@@app_root}/#{options[:canvas_name]}/"
    @canvas_url = options[:canvas_url]
  end

  def auth_url
    @auth_url ||= "https://www.facebook.com/dialog/oauth?client_id=#{Lovers.facebook.id}&redirect_uri=#{Facebook.escape(Lovers.facebook.canvas_page)}"
  end

  # Facebook sends a signed_requests to authenticate certain requests.
  # http://developers.facebook.com/docs/authentication/signed_request/
  def decode_signed_request(signed_request)
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
