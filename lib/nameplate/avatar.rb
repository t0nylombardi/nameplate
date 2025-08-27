# frozen_string_literal: true

require "fileutils"

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
    VERSION = 2 # bump on any change to avatar generation
    FULLSIZE = 600
    FILL_COLOR = "rgba(255, 255, 255, 0.65)" # white at 65% opacity
    FONT_FILE = File.join(File.expand_path("../../", __dir__), "Loto-Light")
  end
end
