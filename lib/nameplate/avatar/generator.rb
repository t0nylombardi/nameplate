# frozen_string_literal: true

module NamePlate
  class Avatar
    # Generates avatar images with robust error handling and logging.
    class Generator
      class GenerationError < StandardError; end

      class ImageMagickError < GenerationError; end

      class FileSystemError < GenerationError; end

      class ConfigurationError < GenerationError; end

      def initialize(username, size, cache: true, logger: nil)
        @username = username
        @size = size
        @cache = cache
        @font = Avatar::FONT_FILE
        @fill = Avatar::FILL_COLOR
        @runner = Shell::CommandRunner.new
        @logger = logger || default_logger

        validate_inputs!
      end

      def self.call(username, size, cache: true, logger: nil)
        new(username, size, cache: cache, logger: logger).execute!
      end

      def execute!
        @logger.info "Starting avatar generation for '#{username}' at size #{size}px"

        begin
          path = generate
          @logger.info "Avatar generation completed successfully: #{path}"
          path
        rescue => e
          @logger.error "Avatar generation failed: #{e.class.name} - #{e.message}"
          @logger.error "Backtrace: #{e.backtrace.first(5).join("\n")}"
          raise
        end
      end

      private

      attr_reader :username, :size, :cache, :font, :fill, :runner, :logger

      def validate_inputs!
        raise ConfigurationError, "Username cannot be empty" if username.nil? || username.strip.empty?
        raise ConfigurationError, "Size must be positive integer" unless size.is_a?(Integer) && size > 0
        raise ConfigurationError, "Font file not found: #{font}" unless font && File.exist?(font)
        raise ConfigurationError, "Fill color not configured" if fill.nil? || fill.empty?
      end

      def generate
        identity = Avatar::Identity.from_username(username)
        target_size = [size, Avatar::FULLSIZE].min

        @logger.debug "Generated identity: #{identity.inspect}"
        @logger.debug "Target size: #{target_size}"

        path = Avatar::Cache.path(identity, target_size)

        if cache && File.exist?(path)
          @logger.info "Using cached avatar: #{path}"
          return path
        end

        ensure_cache_directory_exists!

        fullsize_path = Avatar::Cache.fullsize_path(identity)

        # Generate fullsize if it doesn't exist
        if File.exist?(fullsize_path)
          @logger.debug "Using existing fullsize avatar: #{fullsize_path}"
        else
          @logger.info "Generating fullsize avatar (#{Avatar::FULLSIZE}x#{Avatar::FULLSIZE})"
          generate_fullsize(identity)
          verify_generated_file!(fullsize_path, "fullsize avatar")
        end

        # Resize if needed
        if target_size < Avatar::FULLSIZE
          @logger.info "Resizing avatar from #{Avatar::FULLSIZE} to #{target_size}"
          resize_avatar(fullsize_path, path, target_size)
          verify_generated_file!(path, "resized avatar")
        else
          path = fullsize_path
        end

        path
      end

      def generate_fullsize(identity)
        filename = Avatar::Cache.fullsize_path(identity)

        command = build_imagemagick_command(identity, filename)

        @logger.debug "ImageMagick command: #{command.join(" ")}"

        result = runner.run(command)

        @logger.debug "ImageMagick result: success=#{result.success?}, " \
                     "stdout=#{result.stdout&.strip}, stderr=#{result.stderr&.strip}"

        unless result.success?
          error_msg = build_error_message(result, command)
          raise ImageMagickError, error_msg
        end

        filename
      end

      def build_imagemagick_command(identity, filename)
        [
          "magick",
          "-size", "#{Avatar::FULLSIZE}x#{Avatar::FULLSIZE}",
          "xc:#{to_rgb(identity.color)}",
          "-pointsize", NamePlate.pointsize.to_s,
          "-font", font.to_s,
          "-weight", NamePlate.weight.to_s,
          "-fill", fill.to_s,
          "-gravity", "Center",
          "-annotate", NamePlate.annotate_position.to_s,
          identity.letters.to_s,
          filename.to_s
        ]
      end

      def resize_avatar(source_path, target_path, target_size)
        NamePlate.resize(source_path, target_path, target_size, target_size)
      rescue => e
        raise ImageMagickError, "Failed to resize avatar from #{source_path} to #{target_path}: #{e.message}"
      end

      def build_error_message(result, command)
        parts = []
        parts << "ImageMagick command failed"
        parts << "Exit code: #{result.exit_code}" if result.respond_to?(:exit_code)
        parts << "Command: #{command.join(" ")}"
        parts << "STDOUT: #{result.stdout.strip}" if result.stdout && !result.stdout.strip.empty?
        parts << "STDERR: #{result.stderr.strip}" if result.stderr && !result.stderr.strip.empty?

        # Check for common ImageMagick issues
        if result.stderr&.include?("not authorized")
          parts << "HINT: ImageMagick policy may be blocking this operation. Check /etc/ImageMagick-*/policy.xml"
        elsif result.stderr&.include?("command not found") || result.stderr&.include?("No such file")
          parts << "HINT: ImageMagick may not be installed or not in PATH"
        elsif result.stderr&.include?("unable to read font")
          parts << "HINT: Font file may be corrupted or inaccessible: #{font}"
        end

        parts.join("\n")
      end

      def ensure_cache_directory_exists!
        cache_dir = File.dirname(Avatar::Cache.fullsize_path(Avatar::Identity.from_username(username)))

        unless Dir.exist?(cache_dir)
          @logger.debug "Creating cache directory: #{cache_dir}"
          begin
            FileUtils.mkdir_p(cache_dir)
          rescue => e
            raise FileSystemError, "Failed to create cache directory #{cache_dir}: #{e.message}"
          end
        end
      end

      def verify_generated_file!(path, description)
        unless File.exist?(path)
          raise FileSystemError, "Generated #{description} file does not exist: #{path}"
        end

        if File.size(path) == 0
          raise FileSystemError, "Generated #{description} file is empty: #{path}"
        end

        @logger.debug "Successfully verified #{description}: #{path} (#{File.size(path)} bytes)"
      end

      def to_rgb(color)
        r, g, b = color
        "rgb(#{r},#{g},#{b})"
      rescue => e
        raise ConfigurationError, "Invalid color format: #{color.inspect} - #{e.message}"
      end

      def default_logger
        @default_logger ||= begin
          require "logger"
          logger = Logger.new($stdout)
          logger.level = (ENV["NAMEPLATE_LOG_LEVEL"]&.upcase == "DEBUG") ? Logger::DEBUG : Logger::INFO
          logger.formatter = proc do |severity, datetime, progname, msg|
            "[#{datetime.strftime("%H:%M:%S")}] #{severity}: #{msg}\n"
          end
          logger
        end
      end
    end
  end
end
