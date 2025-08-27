# frozen_string_literal: true

module NamePlate
  module Colors
    module Palettes
      # A "light side" Jedi-inspired palette
      class JediLight < Palette
        COLORS = [
          [255, 255, 255], # pure white
          [0, 87, 183],    # Jedi blue
          [114, 137, 218], # softer blue
          [0, 204, 255],   # cyan/saber glow
          [255, 214, 10],  # light yellow/gold
          [173, 216, 230], # pale blue
          [192, 192, 192]  # silver
        ].freeze

        def self.key = :jedi_light

        def initialize
          super(COLORS)
        end
      end
    end
  end
end
