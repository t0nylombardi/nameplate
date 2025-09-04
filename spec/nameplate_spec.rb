# frozen_string_literal: true

require "spec_helper"

RSpec.describe NamePlate do
  describe ".setup" do
    around do |example|
      original = {
        cache_base_path: described_class.cache_base_path,
        pointsize: described_class.pointsize,
        weight: described_class.weight,
        annotate_pos: described_class.annotate_position
      }

      example.run
    ensure
      described_class.setup do |c|
        c.cache_base_path = original[:cache_base_path]
        c.pointsize = original[:pointsize]
        c.weight = original[:weight]
        c.annotate_position = original[:annotate_pos]
      end
    end

    it "yields the NamePlate module" do
      expect { |blk| described_class.setup(&blk) }.to yield_with_args(described_class)
    end

    it "applies configuration set inside the block" do
      described_class.setup { |c| c.cache_base_path = "tmp/system" }
      expect(described_class.cache_base_path).to eq("tmp/system")
    end
  end

  describe ".generate" do
    it "delegates to Avatar.generate with the same arguments" do
      expect(NamePlate::Avatar).to receive(:generate).with("Tony", 128).and_return("path/to/avatar.png")
      described_class.generate("Tony", 128)
    end

    it "returns the value from Avatar.generate" do
      allow(NamePlate::Avatar).to receive(:generate).and_return("path/to/avatar.png")
      expect(described_class.generate("Tony", 128)).to eq("path/to/avatar.png")
    end
  end

  describe ".resize_image" do
    let(:src) { File.expand_path("../../fixtures/src.png", __dir__) }
    let(:dst) { File.expand_path("../../tmp/out.png", __dir__) }
    let(:width) { 200 }
    let(:height) { 200 }
    let(:resize) { NamePlate::Image::Resize }
    let(:success) { NamePlate::Results::SuccessResult.new(value: {path: "out.png"}) }

    before do
      FileUtils.mkdir_p(File.dirname(src))
      File.write(src, "PNG") unless File.exist?(src)

      FileUtils.mkdir_p(File.dirname(dst))
    end

    after do
      FileUtils.rm_f(src)
      FileUtils.rm_f(dst)
    end

    it "instantiates Image::Resize and calls #resize with keyword args" do
      expect(resize).to receive(:new).with(from: src, to: dst, width:, height:).and_return(resize)
      expect(resize).to receive(:resize!).and_return(success)
      described_class.resize_image(from: src, to: dst, width:, height:)
    end

    it "returns the result object from Image::Resize#resize" do
      allow(resize).to receive(:call).and_return(success)
      expect(
        described_class.resize_image(from: src, to: dst, width:, height:)
      ).to eq(success)
    end
  end

  describe ".resize (legacy)" do
    let(:success) { NamePlate::Results::SuccessResult.new(value: {path: "out.png"}) }
    let(:failure) { NamePlate::Results::FailureResult.new(error: {message: "nope"}) }

    it "returns true when resize_image returns SuccessResult" do
      allow(described_class).to receive(:resize_image).and_return(success)
      expect(described_class.resize_image("in.png", "out.png", 50, 50)).to be(success)
    end

    it "returns false when resize_image returns FailureResult" do
      allow(described_class).to receive(:resize_image).and_return(failure)
      expect(described_class.resize_image("in.png", "out.png", 50, 50)).to be(failure)
    end
  end

  describe ".path_to_url" do
    it "converts a public filesystem path to a URL path" do
      expect(described_class.path_to_url("public/system/nameplate/1/T/226_95_81/64.png"))
        .to eq("/system/nameplate/1/T/226_95_81/64.png")
    end
  end
end
