# frozen_string_literal: true

module NamePlate
  module Colors
    module Palettes
      # Inspired by Dracula theme
      class Dracula < Palette
        COLORS = [
          [40, 42, 54],    # background
          [68, 71, 90],    # current line
          [98, 114, 164],  # comment
          [139, 233, 253], # cyan
          [80, 250, 123],  # green
          [255, 184, 108], # orange
          [255, 121, 198], # pink
          [189, 147, 249], # purple
          [241, 250, 140], # yellow
          [255, 85, 85]    # red
        ].freeze

        def self.key = :dracula

        def initialize
          super(COLORS)
        end
      end
    end
  end
end
