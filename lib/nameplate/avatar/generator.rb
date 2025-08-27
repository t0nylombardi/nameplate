# frozen_string_literal: true

module NamePlate
  class Avatar
    # Generates avatar images.
    class Generator
      def initialize(username, size, cache: true)
        @username = username
        @size = size
        @cache = cache
        @font = Avatar::FONT_FILE
        @fill = Avatar::FILL_COLOR
        @runner = Shell::CommandRunner.new
      end

      def self.call(username, size, cache: true)
        new(username, size, cache: cache).execute!
      end

      def execute!
        generate
      end

      private

      attr_reader :username, :size, :cache, :font, :fill, :runner

      def generate
        identity = Avatar::Identity.from_username(username)
        target_size = [size, Avatar::FULLSIZE].min

        path = Avatar::Cache.path(identity, target_size)
        return path if cache && File.exist?(path)

        fullsize = Avatar::Cache.fullsize_path(identity)
        generate_fullsize(identity) unless cache && File.exist?(fullsize)
        NamePlate.resize(fullsize, path, target_size, target_size) if target_size < Avatar::FULLSIZE

        path
      end

      def generate_fullsize(identity)
        filename = Avatar::Cache.fullsize_path(identity)
        cmd = %W[
          magick convert
          -size #{Avatar::FULLSIZE}x#{Avatar::FULLSIZE}
          xc:#{to_rgb(identity.color)}
          -pointsize #{NamePlate.pointsize}
          -font #{font}
          -weight #{NamePlate.weight}
          -fill '#{fill}'
          -gravity Center
          -annotate #{NamePlate.annotate_position} '#{identity.letters}'
          '#{filename}'
        ]
        filename
      end

      def to_rgb(color)
        r, g, b = color
        "'rgb(#{r},#{g},#{b})'"
      end
    end
  end
end
