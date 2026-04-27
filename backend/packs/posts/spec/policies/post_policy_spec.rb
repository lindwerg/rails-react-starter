require "rails_helper"

RSpec.describe PostPolicy do
  let(:author) { create(:user) }
  let(:other)  { create(:user) }
  let(:published_post) { create(:post, author: author) }
  let(:draft_post)     { create(:post, :draft, author: author) }

  describe "policy actions" do
    it "permits index? for everyone (incl. anon)" do
      expect(described_class.new(nil, published_post)).to permit_actions(%i[index])
    end

    it "permits show? for published to anon and others" do
      expect(described_class.new(other, published_post)).to permit_actions(%i[show])
      expect(described_class.new(nil, published_post)).to permit_actions(%i[show])
    end

    it "forbids show? on drafts to non-author" do
      expect(described_class.new(other, draft_post)).to forbid_actions(%i[show])
      expect(described_class.new(nil, draft_post)).to forbid_actions(%i[show])
    end

    it "permits update?/destroy? only to author" do
      expect(described_class.new(author, draft_post)).to permit_actions(%i[update destroy])
      expect(described_class.new(other, draft_post)).to forbid_actions(%i[update destroy])
    end

    it "permits create? to any logged-in user" do
      expect(described_class.new(other, Post)).to permit_actions(%i[create])
      expect(described_class.new(nil, Post)).to forbid_actions(%i[create])
    end
  end
end
