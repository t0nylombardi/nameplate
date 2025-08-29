# frozen_string_literal: true

module NamePlate
  class Avatar
    # Represents a derived avatar identity: letters and color.
    class Identity
      attr_reader :color, :letters

      def initialize(color, letters)
        @color = color
        @letters = letters
      end

      # Build an identity from a username.
      #
      # @param [String] username The input name.
      # @return [Identity] The derived avatar identity.
      def self.from_username(username)
        color = NamePlate::Colors.for(username)
        letters = initials(username, count(username))
        new(color, letters)
      end

      class << self
        private

        def initials(username, count)
          username
            .split(/\s+/)
            .map { |word| word[0] }
            .join
            .upcase[0..count - 1]
        end

        def count(username)
          (username.strip.split(/\s+/).size >= 2) ? 2 : 1
        end
      end
    end
  end
end
