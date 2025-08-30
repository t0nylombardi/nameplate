# frozen_string_literal: true

require "spec_helper"

RSpec.describe NamePlate::Avatar::Generator do
  let(:identity) { NamePlate::Avatar::Identity.new([226, 95, 81], "T") }
  let(:target_path) { File.expand_path("../../tmp/generated/64.png", __dir__) }
  let(:fake_font) { "/fake/font.ttf" }

  before do
    # Never touch the filesystem
    allow(FileUtils).to receive(:mkdir_p)
    allow(FileUtils).to receive(:rm_f)

    # Ensure MiniMagick constant exists even if the gem isn't loaded
    stub_const("MiniMagick", Module.new) unless defined?(MiniMagick)

    # Avoid any real font lookups or file probes
    allow(NamePlate).to receive(:font).and_return(fake_font)
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(fake_font).and_return(true)

    # Deterministic identity + cache path
    allow(NamePlate::Avatar::Identity).to receive(:from_username).and_return(identity)
    allow(NamePlate::Avatar::Cache).to receive(:path).and_return(target_path)
  end

  describe ".call" do
    it "returns cached path when file exists and cache=true" do
      allow(File).to receive(:exist?).with(target_path).and_return(true)

      path = described_class.call("Tony", 64, cache: true)

      expect(path).to eq(target_path)
    end

    it "generates via MiniMagick when cache miss" do
      allow(File).to receive(:exist?).with(target_path).and_return(false)

      mm_cmd = double("MiniMagick::Command",
        :size => nil, :<< => nil, :pointsize => nil, :font => nil,
        :weight => nil, :fill => nil, :gravity => nil, :annotate => nil)

      expect(MiniMagick).to receive(:convert).and_yield(mm_cmd)

      path = described_class.call("Tony", 64, cache: false)

      expect(path).to eq(target_path)
    end

    it "caps size at Avatar::FULLSIZE" do
      allow(File).to receive(:exist?).with(target_path).and_return(false)

      mm_cmd = double("MiniMagick::Command",
        :size => nil, :<< => nil, :pointsize => nil, :font => nil,
        :weight => nil, :fill => nil, :gravity => nil, :annotate => nil)
      allow(MiniMagick).to receive(:convert).and_yield(mm_cmd)

      # Verify Cache.path receives the clamped size
      expect(NamePlate::Avatar::Cache).to receive(:path) do |_, s|
        expect(s).to eq(NamePlate::Avatar::FULLSIZE)
        target_path
      end

      described_class.call("Tony", NamePlate::Avatar::FULLSIZE + 100, cache: false)
    end
  end

  describe "input validation" do
    it "raises when username is blank" do
      expect { described_class.call(" ", 64) }
        .to raise_error(described_class::ConfigurationError)
    end

    it "raises when size is not positive integer" do
      expect { described_class.call("Tony", 0) }
        .to raise_error(described_class::ConfigurationError)
    end
  end
end
