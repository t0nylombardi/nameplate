# frozen_string_literal: true

require "spec_helper"

RSpec.describe NamePlate::Colors do
  describe ".valid_custom_palette?" do
    it "returns true for a valid palette of hex colors (2..20)" do
      palette = ["#fff", "#a1b2c3", "#123456"]
      expect(described_class.valid_custom_palette?(palette)).to be(true)
    end

    it "returns false for nil" do
      expect(described_class.valid_custom_palette?(nil)).to be(false)
    end

    it "returns false for non-array" do
      expect(described_class.valid_custom_palette?("#fff")).to be(false)
    end

    it "returns false for invalid hex strings" do
      expect(described_class.valid_custom_palette?(["fff", "#12"])).to be(false)
    end

    it "returns false when too few colors" do
      expect(described_class.valid_custom_palette?(["#fff"]))
        .to be(false)
    end

    it "returns false when too many colors" do
      palette = Array.new(21, "#fff")
      expect(described_class.valid_custom_palette?(palette)).to be(false)
    end
  end
end

