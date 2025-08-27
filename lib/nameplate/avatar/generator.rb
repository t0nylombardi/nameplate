# frozen_string_literal: true

module NamePlate
  module Avatar
    # Generates avatar images.
    class Generator
      # @param font [String] path to font file
      # @param fill [String] fill color
      # @param runner [#run] a command runner, defaults to Shell::CommandRunner
      def initialize(font: Avatar::FONT_FILE, fill: Avatar::FILL_COLOR, runner: Shell::CommandRunner.new)
        @font = font
        @fill = fill
        @runner = runner
      end

      # Generate an avatar PNG
      #
      # @param username [String] The display name
      # @param size [Integer] Requested size
      # @param cache [Boolean] Use cached version if available
      # @return [String] Path to generated avatar
      def generate(username, size, cache: true)
        identity = Avatar::Identity.from_username(username)
        size = [size, Avatar::FULLSIZE].min

        path = Avatar::Cache.path(identity, size)
        return path if cache && File.exist?(path)

        fullsize = Avatar::Cache.fullsize_path(identity)
        generate_fullsize(identity) unless cache && File.exist?(fullsize)
        NamePlate.resize(fullsize, path, size, size) if size < Avatar::FULLSIZE

        path
      end

      private

      # @return [String] font path
      # @return [String] fill color
      # @return [#run] command runner
      attr_reader :font, :fill, :runner

      def generate_fullsize(identity)
        filename = Avatar::Cache.fullsize_path(identity)
        cmd = %W[
          magick convert
          -size #{Avatar::FULLSIZE}x#{Avatar::FULLSIZE}
          xc:#{to_rgb(identity.color)}
          -pointsize #{NamePlate.pointsize}
          -font #{@font}
          -weight #{NamePlate.weight}
          -fill '#{@fill}'
          -gravity Center
          -annotate #{NamePlate.annotate_position} '#{identity.letters}'
          '#{filename}'
        ]
        NamePlate.execute(cmd.join(" "))
        filename
      end

      def to_rgb(color)
        r, g, b = color
        "'rgb(#{r},#{g},#{b})'"
      end
    end
  end
end
