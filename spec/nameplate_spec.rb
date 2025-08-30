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
    let(:resizer) { instance_double(NamePlate::Image::Resizer) }
    let(:success) { NamePlate::Results::SuccessResult.new(value: {path: "out.png"}) }

    before do
      allow(NamePlate::Image::Resizer).to receive(:new).and_return(resizer)
    end

    it "instantiates Image::Resizer and calls #resize with keyword args" do
      expect(resizer)
        .to receive(:resize)
        .with(from: "in.png", to: "out.png", width: 100, height: 200)
        .and_return(success)

      described_class.resize_image(from: "in.png", to: "out.png", width: 100, height: 200)
    end

    it "returns the result object from Image::Resizer#resize" do
      allow(resizer).to receive(:resize).and_return(success)
      expect(
        described_class.resize_image(from: "in.png", to: "out.png", width: 100, height: 200)
      ).to eq(success)
    end
  end

  describe ".resize (legacy)" do
    let(:success) { NamePlate::Results::SuccessResult.new(value: {path: "out.png"}) }
    let(:failure) { NamePlate::Results::FailureResult.new(error: {message: "nope"}) }

    it "returns true when resize_image returns SuccessResult" do
      allow(described_class).to receive(:resize_image).and_return(success)
      expect(described_class.resize("in.png", "out.png", 50, 50)).to be(true)
    end

    it "returns false when resize_image returns FailureResult" do
      allow(described_class).to receive(:resize_image).and_return(failure)
      expect(described_class.resize("in.png", "out.png", 50, 50)).to be(false)
    end
  end

  describe ".path_to_url" do
    it "converts a public filesystem path to a URL path" do
      expect(described_class.path_to_url("public/system/nameplate/1/T/226_95_81/64.png"))
        .to eq("/system/nameplate/1/T/226_95_81/64.png")
    end
  end
end
