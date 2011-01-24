module Lovers

  # Generic Lovers exception class
  class LoversError < StandardError
  end

  # Generic exception class for validation of params
  class ParamsInvalid < LoversError
  end

  # Raised when the user isn't logged in (when signed_request is invalid)
  class AuthenticationError < ParamsInvalid
    CODE = "9"
  end

  class NonAppUser < AuthenticationError
    CODE = "8"
  end

  # Raised when the request ID is invalid
  class RequestIdInvalid < ParamsInvalid
    CODE = "7"
  end

  # Raised when the target ID is invalid
  class TargetIdInvalid < ParamsInvalid
    CODE = "6"
  end

end
