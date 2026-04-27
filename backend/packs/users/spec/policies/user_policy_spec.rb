require "rails_helper"

RSpec.describe UserPolicy do
  subject(:policy) { described_class.new(actor, target) }

  let(:target) { create(:user) }

  context "when actor is the same user" do
    let(:actor) { target }

    it { is_expected.to permit_actions(%i[show update destroy]) }
  end

  context "when actor is a different user" do
    let(:actor) { create(:user) }

    it { is_expected.to forbid_actions(%i[show update destroy]) }
  end

  context "when actor is nil" do
    let(:actor) { nil }

    it { is_expected.to forbid_actions(%i[show update destroy]) }
  end
end
