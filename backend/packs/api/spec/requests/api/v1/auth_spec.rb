require "rails_helper"

RSpec.describe "Api::V1::Auth", type: :request do
  describe "POST /api/v1/auth/sign_up" do
    let(:params) { { email: "new@example.com", password: "password123", name: "New" } }

    it "creates a user and returns 201" do
      expect { post "/api/v1/auth/sign_up", params: params }.to change(User, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(json_body[:user][:email]).to eq("new@example.com")
      expect(json_body[:token]).to be_present
    end

    it "returns 422 on validation error" do
      post "/api/v1/auth/sign_up", params: params.merge(password: "short")
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 on duplicate email" do
      create(:user, email: "dup@example.com")
      post "/api/v1/auth/sign_up", params: params.merge(email: "dup@example.com")
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_body[:code]).to eq("email_taken")
    end
  end

  describe "POST /api/v1/auth/sign_in" do
    let!(:user) { create(:user, email: "alice@example.com", password: "password123") }

    it "returns 201 and a token on success" do
      post "/api/v1/auth/sign_in", params: { email: "alice@example.com", password: "password123" }
      expect(response).to have_http_status(:created)
      expect(json_body[:token]).to be_present
    end

    it "returns 401 on bad credentials" do
      post "/api/v1/auth/sign_in", params: { email: "alice@example.com", password: "WRONG" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /api/v1/auth/sign_out" do
    it "clears the cookie and returns 204" do
      user = create(:user)
      delete "/api/v1/auth/sign_out", headers: auth_headers_for(user)
      expect(response).to have_http_status(:no_content)
    end
  end
end
