module Shared
  # Lightweight Result-pattern wrapper. Use as the return value of every
  # service object that can fail.
  #
  # Examples:
  #   Shared::Result.success(user)
  #   Shared::Result.failure(:invalid_credentials, "Wrong email or password")
  Result = Struct.new(:success, :value, :error_code, :error_message, keyword_init: true) do
    def self.success(value = nil)
      new(success: true, value: value)
    end

    def self.failure(error_code, error_message = nil)
      new(success: false, error_code: error_code, error_message: error_message)
    end

    alias_method :success?, :success
    def failure? = !success?
  end
end
