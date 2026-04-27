module Auth
  # Verifies a JWT and returns its payload as a symbolized Hash.
  # Raises Auth::InvalidToken on any verification failure.
  module JwtVerifier
    module_function

    def call(token)
      decoded, = JWT.decode(token, JwtIssuer.secret, true, { algorithm: "HS256" })
      decoded.deep_symbolize_keys
    rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError => e
      raise InvalidToken, e.message
    end
  end
end
