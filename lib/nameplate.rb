# frozen_string_literal: true

# stdlib dependencies used internally
require "open3"
require_relative "nameplate/version"
require_relative "nameplate/configuration"
require_relative "nameplate/results/success_result"
require_relative "nameplate/results/failure_result"
require_relative "nameplate/avatar"
require_relative "nameplate/colors"
require_relative "nameplate/has_avatar"
require_relative "nameplate/image/resize"
require_relative "nameplate/utils/path_helper"
require_relative "nameplate/view_helpers/avatar_helper"

module NamePlate
  extend NamePlate::Configuration

  # Setup DSL for configuration
  #
  # Example:
  #   NamePlate.setup do |config|
  #     config.cache_base_path = "public/system"
  #     config.colors_palette  = :dracula
  #   end
  def self.setup
    yield(self)
  end

  # Public API: generate avatar for a given username
  #
  # @param username [String]
  # @param size [Integer]
  # @return [String] path to generated avatar
  def self.generate(username, size)
    Avatar.generate(username, size)
  end

  # Resize an image and return a structured result
  #
  # @param from [String] source path
  # @param to [String] destination path
  # @param width [Integer]
  # @param height [Integer]
  # @return [SuccessResult, FailureResult]
  def self.resize_image(from:, to:, width:, height:)
    Image::Resize.call(from:, to:, width:, height:)
  end

  # Convert a filesystem path to a URL
  #
  # @param path [String, Pathname]
  # @return [String]
  def self.path_to_url(path)
    Utils::PathHelper.path_to_url(path)
  end
end
