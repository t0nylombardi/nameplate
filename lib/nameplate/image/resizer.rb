# frozen_string_literal: true

require "mini_magick"

module NamePlate
  module Image
    # Resizes images with MiniMagick.
    #
    # Responsibility: take a source image and produce a resized
    # version that fits the requested WxH, centered, with transparent padding.
    #
    # Used by {Avatar::Generator} when a non-fullsize avatar is requested.
    class Resizer
      # Entry point to resize an image.
      #
      # @param from [String] path to the source image file
      # @param to [String] path to the destination image file
      # @param width [Integer] target width in pixels
      # @param height [Integer] target height in pixels
      # @return [NamePlate::Results::SuccessResult, NamePlate::Results::FailureResult]
      def resize(from:, to:, width:, height:)
        validate_inputs!(from: from, to: to, width: width, height: height)

        process_resize(from: from, to: to, width: width, height: height)
      rescue => e
        failure_result(e, from: from, to: to, width: width, height: height)
      end

      private

      # ------------------------------
      # Validation
      # ------------------------------

      def validate_inputs!(from:, to:, width:, height:)
        raise ArgumentError, "Source file not found: #{from}" unless File.exist?(from)
        raise ArgumentError, "Width must be positive integer" unless width.is_a?(Integer) && width.positive?
        raise ArgumentError, "Height must be positive integer" unless height.is_a?(Integer) && height.positive?
        raise ArgumentError, "Destination path cannot be empty" if to.to_s.strip.empty?
      end

      # ------------------------------
      # Processing
      # ------------------------------

      def process_resize(from:, to:, width:, height:)
        image = MiniMagick::Image.open(from)

        image.combine_options do |c|
          c.background "transparent"
          c.gravity "center"
          c.thumbnail "#{width}x#{height}^"
          c.extent "#{width}x#{height}"
          c.unsharp "2x0.5+0.7+0"
          c.quality 98
        end

        image.write(to)
        success_result(to)
      end

      # ------------------------------
      # Result builders
      # ------------------------------

      def success_result(path)
        NamePlate::Results::SuccessResult.new(value: {path: path})
      end

      def failure_result(exception, from:, to:, width:, height:)
        NamePlate::Results::FailureResult.new(
          error: {
            message: "Image resize failed: #{exception.message}",
            exception: exception,
            from: from,
            to: to,
            width: width,
            height: height
          }
        )
      end
    end
  end
end
