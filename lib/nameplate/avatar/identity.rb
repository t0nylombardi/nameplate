# frozen_string_literal: true

module NamePlate
  class Avatar
    # Represents a derived avatar identity: letters and color.
    class Identity
      attr_reader :color, :letters

      # Build an identity from a username.
      #
      # @param username [String] input name
      # @return [Identity]
      def self.from_username(username)
        color = NamePlate::Colors.for(username)
        letters = initials(username, count(username))
        new(color, letters)
      end

      def initialize(color, letters)
        @color = color
        @letters = letters
      end

      private_class_method def self.initials(username, count)
        username
          .split(/\s+/)
          .map { |word| word[0] }
          .join
          .upcase[0..count - 1]
      end

      private_class_method def self.count(username)
        (username.strip.split(/\s+/).size >= 2) ? 2 : 1
      end
    end
  end
end
