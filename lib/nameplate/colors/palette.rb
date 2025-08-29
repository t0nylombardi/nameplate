# frozen_string_literal: true

require "digest"

module NamePlate
  module Colors
    # Base class for all color Palette.
    class Palette
      attr_reader :colors

      def initialize(colors)
        @colors = colors.freeze
      end

      # Select a color based on a username string.
      #
      # @param username [String]
      # @return [Array<Integer>] RGB triplet
      def pick(username)
        index = hash_index(username)
        colors[index % colors.length]
      end

      private

      def hash_index(username)
        Digest::MD5.hexdigest(username)[0...15].to_i(16)
      end
    end
  end
end
