# frozen_string_literal: true

require "spec_helper"

RSpec.describe NamePlate::Avatar::Generator do
  let(:identity) { NamePlate::Avatar::Identity.new([226, 95, 81], "T") }
  let(:target_path) { File.expand_path("../../tmp/generated/64.png", __dir__) }
  let(:fake_font) { "/fake/font.ttf" }
  let(:mm_cmd) do
    double("MiniMagick::Command",
      :size => nil, :<< => nil, :pointsize => nil, :font => nil,
      :weight => nil, :fill => nil, :gravity => nil, :annotate => nil)
  end

  before do
    # Never touch the filesystem
    allow(FileUtils).to receive(:mkdir_p)
    allow(FileUtils).to receive(:rm_f)

    # Stub MiniMagick constant if not loaded
    stub_const("MiniMagick", Module.new) unless defined?(MiniMagick)

    # Avoid any real font lookups
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

      expect(described_class.call("Tony", 64, cache: true)).to eq(target_path)
    end

    it "generates via MiniMagick when cache miss" do
      allow(File).to receive(:exist?).with(target_path).and_return(false)
      expect(MiniMagick).to receive(:convert).and_yield(mm_cmd)

      expect(described_class.call("Tony", 64, cache: false)).to eq(target_path)
    end

    it "caps size at Avatar::FULLSIZE" do
      allow(File).to receive(:exist?).with(target_path).and_return(false)
      allow(MiniMagick).to receive(:convert).and_yield(mm_cmd)

      expect(NamePlate::Avatar::Cache).to receive(:path) do |_, s|
        expect(s).to eq(NamePlate::Avatar::FULLSIZE)
        target_path
      end

      described_class.call("Tony", NamePlate::Avatar::FULLSIZE + 100, cache: false)
    end
  end

  describe ".async_call" do
    before do
      # Always simulate cache miss
      allow(File).to receive(:exist?).with(target_path).and_return(false)
    end

    let(:future) { described_class.async_call("Tony", 64) }

    def stub_minimagick_success
      allow(MiniMagick).to receive(:convert).and_yield(mm_cmd)
    end

    def stub_minimagick_failure(msg = "boom")
      allow(MiniMagick).to receive(:convert).and_raise(msg)
    end

    it "returns a future that resolves to the avatar path" do
      stub_minimagick_success
      expect(future.value!).to eq(target_path)
    end

    it "wraps MiniMagick errors in ImageMagickError" do
      stub_minimagick_failure
      expect { future.value! }.to raise_error(described_class::ImageMagickError, /MiniMagick failed/)
    end

    it "wraps filesystem errors in FileSystemError" do
      allow(NamePlate::Avatar::Cache).to receive(:path).and_raise(Errno::EACCES)
      expect { future.value! }.to raise_error(described_class::FileSystemError, /Permission denied/)
    end

    it "wraps unexpected errors in GenerationError" do
      allow(NamePlate::Avatar::Identity).to receive(:from_username).and_raise("weird failure")
      expect { future.value! }.to raise_error(described_class::GenerationError, /Unexpected error/)
    end
  end

  describe "input validation" do
    [
      {input: [" ", 64], error: described_class::ConfigurationError, description: "blank username"},
      {input: ["Tony", 0], error: described_class::ConfigurationError, description: "non-positive size"},
      {input: ["Tony", -5], error: described_class::ConfigurationError, description: "negative size"}
    ].each do |test_case|
      it "raises #{test_case[:error]} for #{test_case[:description]}" do
        expect { described_class.call(*test_case[:input]) }.to raise_error(test_case[:error])
      end
    end
  end
end
