# frozen_string_literal: true

require "digest"
require_relative "colors/palette"
require_relative "colors/palettes/google"
require_relative "colors/palettes/iwanthue"
require_relative "colors/palettes/custom"

module NamePlate
  module Colors
    # Registry of available palettes
    REGISTRY = {
      google: Palettes::Google.new,
      iwanthue: Palettes::Iwanthue.new,
      custom: Palettes::Custom.new
    }.freeze

    # Pick a color for a given username based on current palette.
    #
    # @param username [String]
    # @return [Array<Integer>] RGB triplet
    def self.for(username)
      palette = REGISTRY.fetch(NamePlate.colors_palette) do
        raise ArgumentError, "Unknown palette: #{NamePlate.colors_palette}"
      end
      palette.pick(username)
    end
  end
end
