require "rails_helper"

RSpec.describe Auth::SignUp do
  describe ".call" do
    it "creates a user and returns success" do
      result = described_class.call(email: "new@example.com", password: "password123", name: "New")
      expect(result).to be_success_result
      expect(result.value).to be_a(User).and have_attributes(email: "new@example.com")
    end

    it "fails with :email_taken when email exists" do
      create(:user, email: "taken@example.com")
      result = described_class.call(email: "taken@example.com", password: "password123")
      expect(result).to be_failure_result(:email_taken)
    end

    it "fails with :validation_failed for short password" do
      result = described_class.call(email: "ok@example.com", password: "short")
      expect(result).to be_failure_result(:validation_failed)
    end

    it "fails with :validation_failed for invalid email" do
      result = described_class.call(email: "not-email", password: "password123")
      expect(result).to be_failure_result(:validation_failed)
    end
  end
end
