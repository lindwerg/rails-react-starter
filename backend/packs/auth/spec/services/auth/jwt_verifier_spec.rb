require "rails_helper"

RSpec.describe Auth::JwtVerifier do
  describe ".call" do
    it "returns the symbolized payload for a valid token" do
      token = Auth::JwtIssuer.call(user_id: 7)
      payload = described_class.call(token)
      expect(payload[:user_id]).to eq(7)
    end

    it "raises Auth::InvalidToken for a tampered token" do
      expect { described_class.call("not.a.token") }.to raise_error(Auth::InvalidToken)
    end

    it "raises Auth::InvalidToken for an expired token" do
      token = Auth::JwtIssuer.call(user_id: 1, expires_in_hours: -1)
      expect { described_class.call(token) }.to raise_error(Auth::InvalidToken)
    end
  end
end
