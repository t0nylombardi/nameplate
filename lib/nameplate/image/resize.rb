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
    class Resize
      # Initializes a new Resize object.
      #
      # @param [String] from path to the source image file
      # @param [String] to path to the destination image file
      # @param [Integer] width target width in pixels
      # @param [Integer] height target height in pixels
      def initialize(from:, to:, width:, height:)
        @from = from
        @to = to
        @width = width
        @height = height
      end

      def self.call(from:, to:, width:, height:)
        new(from:, to:, width:, height:).resize!
      end

      # Entry point to resize an image.
      #
      # @param from [String] path to the source image file
      # @param to [String] path to the destination image file
      # @param width [Integer] target width in pixels
      # @param height [Integer] target height in pixels
      # @return [NamePlate::Results::SuccessResult, NamePlate::Results::FailureResult]
      def resize!
        validate_inputs!
        process_resize
      rescue => e
        failure_result(e, from:, to:, width:, height:)
      end

      private

      attr_reader :from, :to, :width, :height

      # Validates the input parameters.
      #
      # @return [void] if valid
      # @raise [ArgumentError] if any parameter is invalid
      def validate_inputs!
        raise ArgumentError, "Source file not found: #{from}" unless File.exist?(from)
        raise ArgumentError, "Width must be positive integer" unless width.is_a?(Integer) && width.positive?
        raise ArgumentError, "Height must be positive integer" unless height.is_a?(Integer) && height.positive?
        raise ArgumentError, "Destination path cannot be empty" if to.to_s.strip.empty?
      end

      # Processes the image resizing.
      #
      # @return [NamePlate::Results::SuccessResult, NamePlate::Results::FailureResult]
      def process_resize
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

      # Construct a SuccessResult with the given path.
      #
      # @param [String] path the path to the resized image file
      #
      # @return [NamePlate::Results::SuccessResult] the success result
      def success_result(path)
        NamePlate::Results::SuccessResult.new(value: {path:})
      end

      # Construct a FailureResult with the given exception and context.
      #
      # @param [StandardError] exception the raised exception
      # @param [String] from path to the source image file
      # @param [String] to path to the destination image file
      # @param [Integer] width target width in pixels
      # @param [Integer] height target height in pixels
      #
      # @return [NamePlate::Results::FailureResult] the failure result
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
