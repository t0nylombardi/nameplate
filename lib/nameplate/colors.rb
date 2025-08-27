# frozen_string_literal: true

require_relative "colors/palette"

# Auto-require all palette classes
Dir[File.join(__dir__, "colors", "palettes", "*.rb")].sort.each { |f| require f }

module NamePlate
  module Colors
    # Lazily build registry from all subclasses of Palette
    def self.registry
      @registry ||= Palettes.constants.map do |const|
        klass = Palettes.const_get(const)
        next unless klass.is_a?(Class) && klass < Palette
        [klass.key, klass.new]
      end.compact.to_h.freeze
    end

    def self.for(username)
      palette = registry.fetch(NamePlate.colors_palette) do
        raise ArgumentError, "Unknown palette: #{NamePlate.colors_palette}"
      end
      palette.pick(username)
    end
  end
end
