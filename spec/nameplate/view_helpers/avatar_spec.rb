# frozen_string_literal: true

require "spec_helper"

RSpec.describe NamePlate::ViewHelpers::Avatar do
  let(:dummy_view) do
    Class.new do
      include NamePlate::ViewHelpers::Avatar
    end.new
  end

  before do
    allow(NamePlate::Avatar).to receive(:generate).and_return("public/system/nameplate/1/T/226_95_81/64.png")
    allow(NamePlate).to receive(:path_to_url).and_call_original
  end

  describe "#letter_avatar_for" do
    it "delegates to NamePlate::Avatar.generate" do
      expect(NamePlate::Avatar).to receive(:generate).with("Tony", 64)
      dummy_view.letter_avatar_for("Tony", 64)
    end
  end

  describe "#letter_avatar_url" do
    it "returns URL path derived from generated path" do
      url = dummy_view.letter_avatar_url("Tony", 64)
      expect(url).to eq("/system/nameplate/1/T/226_95_81/64.png")
    end
  end

  describe "#letter_avatar_tag" do
    it "renders a plain img tag when AssetTagHelper is not defined" do
      hide_const("ActionView::Helpers::AssetTagHelper") if defined?(ActionView::Helpers::AssetTagHelper)
      html = dummy_view.letter_avatar_tag("Tony", 64, class: "avatar")
      expect(html).to eq('<img alt="Tony" class="avatar" src="/system/nameplate/1/T/226_95_81/64.png" />')
    end
  end
end

