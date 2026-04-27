module Auth
  # Verifies email + password. Returns Result.success(user) or
  # Result.failure(:invalid_credentials, "...").
  module SignIn
    module_function

    def call(email:, password:)
      user = User.find_by("LOWER(email) = ?", email.to_s.downcase.strip)
      if user&.authenticate(password)
        Shared::Result.success(user)
      else
        Shared::Result.failure(:invalid_credentials, "Invalid email or password")
      end
    end
  end
end
