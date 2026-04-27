require "rails_helper"

RSpec.describe Auth::SignIn do
  describe ".call" do
    let!(:user) { create(:user, email: "alice@example.com", password: "password123") }

    it "returns success when credentials match" do
      result = described_class.call(email: "alice@example.com", password: "password123")
      expect(result).to be_success_result
      expect(result.value).to eq(user)
    end

    it "is case-insensitive on email" do
      result = described_class.call(email: "ALICE@example.com", password: "password123")
      expect(result).to be_success_result
    end

    it "fails with :invalid_credentials when password is wrong" do
      result = described_class.call(email: "alice@example.com", password: "wrong")
      expect(result).to be_failure_result(:invalid_credentials)
    end

    it "fails with :invalid_credentials when user doesn't exist" do
      result = described_class.call(email: "nope@example.com", password: "password123")
      expect(result).to be_failure_result(:invalid_credentials)
    end
  end
end
