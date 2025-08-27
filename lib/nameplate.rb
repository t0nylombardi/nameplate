# frozen_string_literal: true

require "open3"
require "nameplate/version"
require "nameplate/configuration"
require "nameplate/result"
require "nameplate/errors"
require "nameplate/shell/command_runner"
require "nameplate/image/resizer"
require "nameplate/utils/path_helper"
require "nameplate/avatar"
require "nameplate/avatar_helper"
require "nameplate/colors"

module NamePlate
  extend NamePlate::Configuration

  # Setup DSL for configuration
  def self.setup
    yield(self)
  end

  def self.generate(username, size)
    Avatar.generate(username, size)
  end

  # SOLID facade: returns SuccessResult/FailureResult
  def self.resize_image(from:, to:, width:, height:)
    Image::Resizer.new.resize(from: from, to: to, width: width, height: height)
  end

  # Legacy API: true/false
  def self.resize(from, to, width, height)
    resize_image(from: from, to: to, width: width, height: height).success?
  end

  def self.path_to_url(path)
    Utils::PathHelper.path_to_url(path)
  end
end
