# frozen_string_literal: true

module NamePlate
  module Results
    # Represents a successful operation result.
    #
    # Provides a consistent API for checking success
    # and accessing the returned value.
    class SuccessResult
      attr_reader :value

      def initialize(value:)
        @value = value
      end

      # @return [Boolean]
      def success?
        true
      end

      # @return [Boolean]
      def failure?
        false
      end
    end
  end
end
