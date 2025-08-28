# frozen_string_literal: true

require "open3"

module NamePlate
  module Shell
    # Runs external commands with explicit argument arrays (no shell eval).
    # Single Responsibility: Execute a command and capture outputs.
    #
    # Returns SuccessResult or FailureResult with stdout/stderr/status.
    class CommandRunner
      # Execute a command safely.
      #
      # @param argv [Array<String>] the command and its arguments
      # @return [NamePlate::Results::SuccessResult, NamePlate::Results::FailureResult]
      def run(argv)
        validate_argv!(argv)

        stdout, stderr, status = Open3.capture3(*argv)
        puts "Command stdout: #{stdout.inspect}"
        puts "Command stderr: #{stderr.inspect}"
        puts "Command status: #{status.inspect}"
        if status.success? && stderr.to_s.strip.empty?
          success_result(stdout: stdout, status: status)
        else
          failure_result(argv: argv, stdout: stdout, stderr: stderr, status: status)
          puts "Command failed: #{stderr.inspect}"
        end
      rescue => e
        failure_result(exception: e)
      end

      private

      def validate_argv!(argv)
        return if argv.is_a?(Array) && argv.all? { |a| a.is_a?(String) && !a.empty? }
        raise ArgumentError, "argv must be a non-empty Array<String>"
      end

      def success_result(stdout:, status:)
        NamePlate::Results::SuccessResult.new(value: {stdout: stdout, status: status})
      end

      def failure_result(argv: nil, stdout: nil, stderr: nil, status: nil, exception: nil)
        NamePlate::Results::FailureResult.new(
          error: {
            message: exception ? exception.message : "Command failed",
            argv: argv,
            stdout: stdout,
            stderr: stderr,
            status: status,
            exception: exception
          }.compact
        )
      end
    end
  end
end
