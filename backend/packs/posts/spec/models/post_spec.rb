require "rails_helper"

RSpec.describe Post do
  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_length_of(:title).is_at_most(200) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:author).class_name("User") }
  end

  describe "scopes" do
    it "published returns only published-and-not-future posts" do
      published = create(:post)
      _draft = create(:post, :draft)
      _future = create(:post, :scheduled)
      expect(Post.published).to contain_exactly(published)
    end
  end

  describe "#published?" do
    it { expect(build(:post).published?).to be(true) }
    it { expect(build(:post, :draft).published?).to be(false) }
    it { expect(build(:post, :scheduled).published?).to be(false) }
  end
end
