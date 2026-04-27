require "rails_helper"

RSpec.describe Posts::Update do
  let(:post) { create(:post, :draft, title: "Old", body: "Old body") }

  it "updates fields and returns success" do
    result = described_class.call(post: post, attrs: { title: "New", body: "New body" })
    expect(result).to be_success_result
    expect(post.reload).to have_attributes(title: "New", body: "New body")
  end

  it "publishes when publish: true is passed" do
    result = described_class.call(post: post, attrs: { title: "x", body: "y", publish: true })
    expect(result).to be_success_result
    expect(post.reload.published?).to be(true)
  end

  it "fails on invalid input" do
    result = described_class.call(post: post, attrs: { title: "", body: "y" })
    expect(result).to be_failure_result(:validation_failed)
  end
end
