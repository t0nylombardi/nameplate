# frozen_string_literal: true

require "spec_helper"

RSpec.describe NamePlate::Image::Resizer do
  subject(:resizer) { described_class.new }

  let(:src) { File.expand_path("../../fixtures/src.png", __dir__) }
  let(:dst) { File.expand_path("../../tmp/out.png", __dir__) }

  before do
    # Ensure a readable fake source file exists
    FileUtils.mkdir_p(File.dirname(src))
    File.write(src, "PNG") unless File.exist?(src)
    # Ensure tmp dir exists; destination file will be written by MiniMagick mock
    FileUtils.mkdir_p(File.dirname(dst))
  end

  after do
    FileUtils.rm_f(src)
    FileUtils.rm_f(dst)
  end

  describe "validation" do
    it "fails when source does not exist" do
      result = resizer.resize(from: "missing.png", to: dst, width: 10, height: 10)
      expect(result).to be_a(NamePlate::Results::FailureResult)
      expect(result.error[:message]).to include("Source file not found")
    end

    it "fails when width is not positive" do
      result = resizer.resize(from: src, to: dst, width: 0, height: 10)
      expect(result).to be_a(NamePlate::Results::FailureResult)
      expect(result.error[:message]).to include("Width must be positive integer")
    end

    it "fails when height is not positive" do
      result = resizer.resize(from: src, to: dst, width: 10, height: 0)
      expect(result).to be_a(NamePlate::Results::FailureResult)
      expect(result.error[:message]).to include("Height must be positive integer")
    end

    it "fails when destination path is empty" do
      result = resizer.resize(from: src, to: "  ", width: 10, height: 10)
      expect(result).to be_a(NamePlate::Results::FailureResult)
      expect(result.error[:message]).to include("Destination path cannot be empty")
    end
  end

  describe "processing" do
    let(:image_double) do
      instance_double(MiniMagick::Image,
        combine_options: nil,
        write: true)
    end

    before do
      allow(MiniMagick::Image).to receive(:open).with(src).and_return(image_double)
      allow(image_double).to receive(:combine_options).and_yield(command_double)
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

    it "returns SuccessResult on successful resize" do
      result = resizer.resize(from: src, to: dst, width: 80, height: 60)
      expect(result).to be_a(NamePlate::Results::SuccessResult)
      expect(result.value[:path]).to eq(dst)
    end

    it "returns FailureResult when MiniMagick raises" do
      allow(MiniMagick::Image).to receive(:open).and_raise(StandardError, "boom")
      result = resizer.resize(from: src, to: dst, width: 80, height: 60)
      expect(result).to be_a(NamePlate::Results::FailureResult)
      expect(result.error[:message]).to include("Image resize failed: boom")
      expect(result.error[:from]).to eq(src)
      expect(result.error[:to]).to eq(dst)
    end
  end
end
