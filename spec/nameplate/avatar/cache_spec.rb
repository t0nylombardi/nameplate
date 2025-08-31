# frozen_string_literal: true

require "spec_helper"

RSpec.describe NamePlate::Avatar::Cache do
  let(:tmpdir) { File.expand_path("../../tmp/cache", __dir__) }

  before do
    FileUtils.rm_rf(tmpdir)
    FileUtils.mkdir_p(tmpdir)
    @orig = NamePlate.cache_base_path
    NamePlate.cache_base_path = tmpdir
  end

  after do
    NamePlate.cache_base_path = @orig
    FileUtils.rm_rf(tmpdir)
  end

  let(:identity) { NamePlate::Avatar::Identity.new([226, 95, 81], "T") }

  describe ".base_path" do
    it "builds base path with version" do
      expect(described_class.base_path).to eq(File.join(tmpdir, "nameplate", NamePlate::Avatar::VERSION.to_s))
    end
  end

  describe ".path" do
    it "creates directories and returns full file path" do
      path = described_class.path(identity, 64)
      expect(path).to end_with("/T/226_95_81/64.png")
      expect(File).to exist(File.dirname(path))
    end
  end
end
