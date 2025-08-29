# frozen_string_literal: true

module NamePlate
  module Colors
    module Palettes
      # Inspired by Monokai theme
      class Monokai < Palette
        COLORS = [
          [39, 40, 34],    # background
          [248, 248, 242], # foreground
          [249, 38, 114],  # pink
          [166, 226, 46],  # green
          [253, 151, 31],  # orange
          [102, 217, 239], # cyan
          [174, 129, 255], # purple
          [230, 219, 116]  # yellow
        ].freeze

        def self.key = :monokai

        def initialize
          super(COLORS)
        end
      end
    end
  end
end
