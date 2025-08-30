# frozen_string_literal: true

require_relative "colors/palette"

# Auto-require all palette classes
Dir[File.join(__dir__ || Dir.pwd, "colors", "palettes", "*.rb")].sort.each { |f| require f }

module NamePlate
  module Colors
    # Lazily build registry from all subclasses of Palette
    def self.registry
      @registry ||= Palettes.constants.map do |const|
        klass = Palettes.const_get(const)
        # @type var klass: NamePlate::Colors::_PaletteClass

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

    # Validate a custom palette of colors.
    #
    # @param [Array[Integer]] palette The custom palette of colors.
    # @return [Boolean] Whether the custom palette is valid.
    def self.valid_custom_palette?(palette)
      return false if palette.nil?
      return false unless palette.is_a?(Array)
      return false unless palette.all? { |c| c.is_a?(String) && c.match?(/\A#(?:[0-9a-fA-F]{3}){1,2}\z/) }
      return false if palette.size < 2
      return false if palette.size > 20
      true
    end
  end
end
