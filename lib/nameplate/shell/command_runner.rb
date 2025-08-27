# frozen_string_literal: true

require "open3"

module NamePlate
  module Shell
    # Runs external commands with explicit argument arrays (no shell eval).
    # Single Responsibility: Execute a command and capture outputs.
    #
    # Usage:
    #   runner = Shell::CommandRunner.new
    #   result = runner.run(%w[magick convert in.png -resize 100x100 out.png])
    #
    # Returns SuccessResult or FailureResult with stdout/stderr/status.
    class CommandRunner
      # Execute a command safely.
      #
      # @param argv [Array<String>] the command and its arguments
      # @return [SuccessResult, FailureResult]
      def run(argv)
        validate_argv!(argv)

        stdout, stderr, status = Open3.capture3(*argv)

        return failure(argv, stdout, stderr, status) unless status.success? && stderr.to_s.strip.empty?

        NamePlate::Results::SuccessResult.new(value: {stdout: stdout, status: status})
      rescue => e
        NamePlate::Results::FailureResult.new(error: {message: e.message, exception: e})
      end

      private

      # Ensure argv is a valid non-empty array of strings
      #
      # @param argv [Object]
      # @raise [ArgumentError] if argv is not valid
      def validate_argv!(argv)
        return if argv.is_a?(Array) && argv.all? { |a| a.is_a?(String) && !a.empty? }

        raise ArgumentError, "argv must be a non-empty Array<String>"
      end

      # Build a failure result
      #
      # @param argv [Array<String>]
      # @param stdout [String]
      # @param stderr [String]
      # @param status [Process::Status]
      # @return [FailureResult]
      def failure(argv, stdout, stderr, status)
        FailureResult.new(
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
