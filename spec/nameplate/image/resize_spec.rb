# frozen_string_literal: true

require "spec_helper"

RSpec.describe NamePlate::Image::Resize do
  let(:src) { File.expand_path("../../fixtures/src.png", __dir__) }
  let(:dst) { File.expand_path("../../tmp/out.png", __dir__) }
  let(:width) { 200 }
  let(:height) { 200 }

  before do
    FileUtils.mkdir_p(File.dirname(src))
    File.write(src, "PNG") unless File.exist?(src)

    FileUtils.mkdir_p(File.dirname(dst))
  end

  after do
    FileUtils.rm_f(src)
    FileUtils.rm_f(dst)
  end

  describe ".call" do
    context "when source does not exist" do
      it "returns FailureResult" do
        result = described_class.call(from: "missing.png", to: dst, width: 10, height: 10)

        expect(result).to be_a(NamePlate::Results::FailureResult)
      end
    end

    context "when width is not positive" do
      it "returns FailureResult" do
        result = described_class.call(from: src, to: dst, width: 0, height: 10)

        expect(result.error[:message]).to include("Width must be positive integer")
      end
    end

    context "when height is not positive" do
      it "returns FailureResult" do
        result = described_class.call(from: src, to: dst, width: 10, height: 0)

        expect(result.error[:message]).to include("Height must be positive integer")
      end
    end

    context "when destination path is empty" do
      it "returns FailureResult" do
        result = described_class.call(from: src, to: "   ", width: 10, height: 10)

        expect(result.error[:message]).to include("Destination path cannot be empty")
      end
    end

    context "when MiniMagick processes successfully" do
      let(:image_double) do
        instance_double(MiniMagick::Image, combine_options: nil, write: true)
      end

      let(:command_double) do
        double("MiniMagick::Command").tap do |d|
          allow(d).to receive(:background)
          allow(d).to receive(:gravity)
          allow(d).to receive(:thumbnail)
          allow(d).to receive(:extent)
          allow(d).to receive(:unsharp)
          allow(d).to receive(:quality)
        end
      end

      before do
        allow(MiniMagick::Image).to receive(:open).with(src).and_return(image_double)
        allow(image_double).to receive(:combine_options).and_yield(command_double)
      end

      it "returns SuccessResult with the destination path" do
        result = described_class.call(from: src, to: dst, width: 80, height: 60)

        expect(result.value[:path]).to eq(dst)
      end
    end

    context "when MiniMagick raises an error" do
      before do
        allow(MiniMagick::Image).to receive(:open).and_raise(StandardError, "boom")
      end

      it "returns FailureResult with error details" do
        result = described_class.call(from: src, to: dst, width: 80, height: 60)

        expect(result.error[:message]).to include("Image resize failed: boom")
      end
    end
  end
end
