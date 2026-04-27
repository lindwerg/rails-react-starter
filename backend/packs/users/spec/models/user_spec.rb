require "rails_helper"

RSpec.describe User do
  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to allow_value("a@b.co").for(:email) }
    it { is_expected.not_to allow_value("not-an-email").for(:email) }
    it { is_expected.to have_secure_password }
    it { is_expected.to validate_length_of(:password).is_at_least(8) }
  end

  describe "normalization" do
    it "downcases and strips email before save" do
      user = create(:user, email: "  HELLO@World.COM  ")
      expect(user.reload.email).to eq("hello@world.com")
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:posts).dependent(:destroy) }
  end
end
