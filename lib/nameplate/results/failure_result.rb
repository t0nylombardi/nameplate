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
      def failure(argv, stdout, stderr, status)
        NamePlate::Results::FailureResult.new(
          error: {
            message: "Command failed",
            argv: argv,
            stdout: stdout,
            stderr: stderr,
            status: status
          }
        )
      end
    end
  end
end
