module NamePlate
  module Image
    # Image resizing with ImageMagick.
    #
    # This class encapsulates how we call ImageMagick across platforms.
    # It accepts a CommandRunner (dependency injection) to keep it testable.
    class Resizer
      # ImageMagick entrypoint.
      # The convert command is deprecated in IMv7, use "magick" instead of "convert" or "magick convert"
      IM_CMD = ["magick"].freeze

      def initialize(runner: Shell::CommandRunner.new)
        @runner = runner
      end

      # Resize an image to a fixed WxH canvas, centered, preserving content.
      #
      # @param from [String] path to the source image file
      # @param to [String] path to the destination image file
      # @param width [Integer] target width in pixels
      # @param height [Integer] target height in pixels
      # @return [SuccessResult, FailureResult]
      #
      # Notes on flags:
      # -background transparent : ensure padded area is transparent
      # -gravity center         : center the subject
      # -thumbnail WxH^         : scale to fill; may crop
      # -extent WxH             : ensure exact canvas size
      # -unsharp 2x0.5+0.7+0    : mild sharpening
      # -quality 98             : write quality (format-dependent)
      def resize(from:, to:, width:, height:)
        width = Integer(width)
        height = Integer(height)

        argv = IM_CMD + build_argv(from, to, width, height)
        result = @runner.run(argv)

        raise "Image resize failed: no result from command runner" unless result

        result
      end

      private

      def build_argv(from, to, width, height)
        [
          *IM_CMD,
          from,
          "-background", "transparent",
          "-gravity", "center",
          "-thumbnail", "#{width}x#{height}^",
          "-extent", "#{width}x#{height}",
          "-unsharp", "2x0.5+0.7+0",
          "-quality", "98",
          to
        ]
      end

      def failure_result(result:)
        NamePlate::Results::FailureResult.new(
          error: {
            message: "Image resize failed",
            details: result.error[:message],
            status: result.error[:status],
            stdout: result.error[:stdout],
            stderr: result.error[:stderr]
          }
        )
      end
    end
  end
end
