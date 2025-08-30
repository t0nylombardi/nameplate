# frozen_string_literal: true

require "fileutils"
require_relative "avatar/generator"
require_relative "avatar/cache"
require_relative "avatar/identity"

module NamePlate
  # Avatar generation from usernames.
  #
  # Responsibilities are split into:
  # - {Identity}: maps username → initials + color
  # - {Cache}: builds consistent cache paths
  # - {Generator}: orchestrates avatar creation and resizing
  #
  # Public API:
  #   NamePlate::Avatar.generate("John Doe", 128)
  #
  class Avatar
    VERSION = 1 # bump on any change to avatar generation
    FULLSIZE = 600
    FILL_COLOR = "rgba(255, 255, 255, 0.65)" # white at 65% opacity
    # Use __dir__ and fall back to the current working directory for Steep
    # which can type __dir__ as String | nil.
    FONT_FILE = File.expand_path("fonts/Roboto-Medium", __dir__ || Dir.pwd)

    # Public API entry point
    #
    # @param username [String]
    # @param size [Integer]
    # @param opts [Hash] options, e.g. { cache: true }
    # @return [String] path to avatar file
    def self.generate(username, size, opts = {})
      Generator.call(username, size, **opts)
    end
  end
end
