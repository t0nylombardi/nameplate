# frozen_string_literal: true

module NamePlate
  module Results
    # Represents a failed operation result.
    #
    # Provides a consistent API for checking failure
    # and accessing error details.
    class FailureResult
      attr_reader :error

      def initialize(error:)
        @error = error
      end

      # @return [Boolean]
      def success?
        false
      end

      # @return [Boolean]
      def failure?
        true
      end
    end
  end
end
