module Auth
  # Issues a signed JWT for a given user_id.
  module JwtIssuer
    module_function

    def call(user_id:, expires_in_hours: nil)
      hours = (expires_in_hours || ENV.fetch("JWT_EXPIRES_IN_HOURS", 24)).to_i
      payload = {
        user_id: user_id,
        iat: Time.current.to_i,
        exp: hours.hours.from_now.to_i
      }
      JWT.encode(payload, secret, "HS256")
    end

    def secret
      ENV.fetch("JWT_SECRET") { Rails.application.secret_key_base }
    end
  end
end
