require "rails_helper"

RSpec.describe "Api::V1::Me", type: :request do
  describe "GET /api/v1/me" do
    let(:user) { create(:user, email: "alice@example.com") }

    it "returns the current user when authenticated" do
      get "/api/v1/me", headers: auth_headers_for(user)
      expect(response).to have_http_status(:ok)
      expect(json_body[:email]).to eq("alice@example.com")
    end

    it "returns 401 without a token" do
      get "/api/v1/me"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 with an invalid token" do
      get "/api/v1/me", headers: { "Authorization" => "Bearer not.a.token" }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
