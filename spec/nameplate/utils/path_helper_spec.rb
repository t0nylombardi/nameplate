# frozen_string_literal: true

require "spec_helper"

RSpec.describe Utils::PathHelper do
  describe ".path_to_url" do
    it "strips leading public/ and prefixes with /" do
      expect(described_class.path_to_url("public/system/nameplate/1/T/226_95_81/64.png"))
        .to eq("/system/nameplate/1/T/226_95_81/64.png")
    end

    it "returns string unchanged if it does not start with public/" do
      expect(described_class.path_to_url("/system/nameplate/a.png")).to eq("/system/nameplate/a.png")
    end
  end
end
