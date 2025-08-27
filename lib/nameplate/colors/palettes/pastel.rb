# frozen_string_literal: true

module NamePlate
  module Colors
    module Palettes
      # A soft pastel theme
      class Pastel < Palette
        COLORS = [
          [255, 179, 186], # light pink
          [255, 223, 186], # peach
          [255, 255, 186], # light yellow
          [186, 255, 201], # mint
          [186, 225, 255]  # baby blue
        ].freeze

        def self.key = :pastel

        def initialize
          super(COLORS)
        end
      end
    end
  end
end
