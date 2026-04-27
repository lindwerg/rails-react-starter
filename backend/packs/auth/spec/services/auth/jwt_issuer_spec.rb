require "rails_helper"

RSpec.describe Auth::JwtIssuer do
  describe ".call" do
    it "encodes a JWT with user_id and exp" do
      token = described_class.call(user_id: 42, expires_in_hours: 1)
      decoded, = JWT.decode(token, described_class.secret, true, { algorithm: "HS256" })

      expect(decoded["user_id"]).to eq(42)
      expect(decoded["exp"]).to be_within(120).of(1.hour.from_now.to_i)
    end
  end
end
