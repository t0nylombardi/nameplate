# frozen_string_literal: true

require_relative "colors/palette"

# Auto-require everything in palettes folder
Dir[File.join(__dir__, "colors", "palettes", "*.rb")].sort.each { |f| require f }

module NamePlate
  module Colors
    # Build registry by finding all subclasses of Palette
    REGISTRY = Palettes.constants.map do |const|
      klass = Palettes.const_get(const)
      next unless klass.is_a?(Class) && klass < Palette
      [klass.key, klass.new]
    end.compact.to_h.freeze

    # Pick a color for a given username based on the current palette
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
