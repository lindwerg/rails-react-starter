module Auth
  # Registers a new user and returns Result.success(user) on success,
  # Result.failure(:validation_failed, errors) on invalid input,
  # Result.failure(:email_taken, "...") on dup email.
  module SignUp
    module_function

    def call(email:, password:, name: nil)
      user = User.new(email: email, password: password, name: name.to_s)
      if user.save
        Shared::Result.success(user)
      else
        code = user.errors.of_kind?(:email, :taken) ? :email_taken : :validation_failed
        Shared::Result.failure(code, user.errors.full_messages.join(", "))
      end
    end
  end
end
