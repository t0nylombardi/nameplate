# frozen_string_literal: true

module NamePlate
  module Colors
    module Palettes
      class Custom < Palette
        def self.key = :custom

        def initialize
          super(NamePlate.custom_palette || [])
        end

        def pick(username)
          raise "Custom palette not set" if colors.empty?
          super
        end
      end
    end
  end
end
