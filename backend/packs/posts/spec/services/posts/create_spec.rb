require "rails_helper"

RSpec.describe Posts::Create do
  describe ".call" do
    let(:author) { create(:user) }

    it "creates a draft when publish is false/missing" do
      result = described_class.call(author: author, attrs: { title: "Hi", body: "There" })
      expect(result).to be_success_result
      expect(result.value).to be_persisted
      expect(result.value.published?).to be(false)
    end

    it "creates a published post when publish: true" do
      result = described_class.call(author: author, attrs: { title: "Hi", body: "There", publish: true })
      expect(result).to be_success_result
      expect(result.value.published?).to be(true)
    end

    it "fails with :validation_failed when title is blank" do
      result = described_class.call(author: author, attrs: { title: "", body: "x" })
      expect(result).to be_failure_result(:validation_failed)
    end

    it "fails with :validation_failed when title is too long" do
      result = described_class.call(author: author, attrs: { title: "a" * 201, body: "x" })
      expect(result).to be_failure_result(:validation_failed)
    end
  end
end
