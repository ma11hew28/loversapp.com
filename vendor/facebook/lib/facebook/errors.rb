class Facebook
  # Generic Facebook exception class
  class FacebookError < StandardError
  end

  # Raised when the Graph API responds with error
  class APIError < FacebookError
  end

  # Raised when signed_request can't be decoded or is invalid
  class AuthenticationError < FacebookError
  end
end
