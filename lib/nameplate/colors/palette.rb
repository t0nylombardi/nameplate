# frozen_string_literal: true

require "digest"

module NamePlate
  module Colors
    class Palette
      attr_reader :colors

      # Allow zero-arg construction for the registry
      def initialize(colors = nil)
        colors ||= self.class.const_get(:COLORS)
        @colors = colors.freeze
      end

      def self.key
        raise NotImplementedError, "#{self}.key must return a Symbol"
      end

      # Select a color based on a username string.
      #
      # @param [String] username The username to base the color selection on.
      # @return [Array<Integer>] RGB triplet
      def pick(username)
        index = hash_index(username)
        colors[index % colors.length]
      end

      private

      # Generate a hash index from a username.
      #
      # @param [String] username The username to hash.
      # @return [Integer] The hash index.
      def hash_index(username)
        Digest::MD5.hexdigest(username)[0...15].to_i(16)
      end
    end
  end
end
