# frozen_string_literal: true

require "spec_helper"

RSpec.describe NamePlate::Avatar::Identity do
  describe ".from_username" do
    before do
      allow(NamePlate::Colors).to receive(:for).and_return([1, 2, 3])
    end

    it "uses first letter for single-word usernames" do
      identity = described_class.from_username("tony")
      expect(identity.letters).to eq("T")
      expect(identity.color).to eq([1, 2, 3])
    end

    it "uses two letters for multi-word usernames" do
      identity = described_class.from_username("Tony Lombardi")
      expect(identity.letters).to eq("TL")
    end

    it "upcases letters and trims whitespace" do
      identity = described_class.from_username("  ada  ")
      expect(identity.letters).to eq("A")
    end
  end
end
