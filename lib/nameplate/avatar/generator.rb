# frozen_string_literal: true

require "mini_magick"

module NamePlate
  class Avatar
    # Generates PNG avatars from usernames using MiniMagick/ImageMagick.
    #
    # - Derives an {Identity} (initial letters + background color) from a username.
    # - Produces a square PNG at the requested size (capped at {Avatar::FULLSIZE}).
    # - Uses {Avatar::Cache} to reuse existing files and to build deterministic paths.
    #
    # The high-level API for consumers is {NamePlate::Avatar.generate}. This class
    # exists as the lower-level, orchestration entry point that handles logging,
    # validation, caching, and MiniMagick invocation.
    #
    # Requirements:
    # - ImageMagick must be installed and accessible on the PATH (MiniMagick uses `convert`).
    # - A valid font file must be configured at {Avatar::FONT_FILE}.
    #
    # Configuration sources used during generation:
    # - `NamePlate.pointsize`, `NamePlate.weight`, `NamePlate.annotate_position`
    # - {Avatar::FILL_COLOR} (foreground text/letters color)
    # - {Avatar::FONT_FILE} (font used by ImageMagick)
    # - `NamePlate.cache_base_path` (root for cached files; see {Avatar::Cache})
    # - `ENV["NAMEPLATE_LOG_LEVEL"]` (set to `DEBUG` for verbose logging)
    #
    # @example Generate and return a cached 128px avatar path
    #   path = NamePlate::Avatar::Generator.call("Tony Baloney", 128)
    #   # => "public/system/nameplate/1/TB/163_163_163/128.png"
    #
    # @example Disable cache and provide a custom logger
    #   logger = Logger.new($stderr)
    #   path = NamePlate::Avatar::Generator.call("Ada Lovelace", 256, cache: false, logger: logger)
    #   # Generates a fresh 256px PNG even if a cached one exists
    #
    # @see NamePlate::Avatar.generate User-facing convenience API
    # @see NamePlate::Avatar::Cache Path building and cache helpers
    class Generator
      # Base class for avatar generation errors
      # @abstract
      # @since 1.0.0
      class GenerationError < StandardError; end

      # Raised when MiniMagick/ImageMagick fails to render an avatar.
      # @since 1.0.0
      class ImageMagickError < GenerationError; end

      # Raised when filesystem operations (write/verify) fail.
      # @since 1.0.0
      class FileSystemError < GenerationError; end

      # Raised when inputs or configuration are invalid.
      # @since 1.0.0
      class ConfigurationError < GenerationError; end

      # Instantiate a new generator.
      #
      # Prefer {::call} unless you need a long-lived instance.
      #
      # @param username [String] The source name used to derive initials and color.
      # @param size [Integer] Target size in pixels (> 0). Capped at {Avatar::FULLSIZE}.
      # @param cache [Boolean] Reuse existing cached PNG when present. Defaults to `true`.
      # @param logger [Logger, nil] Optional logger; defaults to a simple STDOUT logger.
      # @raise [ConfigurationError] If parameters are invalid or required assets are missing.
      def initialize(username, size, cache: true, logger: nil)
        @username = username
        @size = size
        @cache = cache
        @font = Avatar::FONT_FILE
        @fill = Avatar::FILL_COLOR
        @logger = logger || default_logger

        validate_inputs!
      end

      # Convenience entry point that builds, runs, and returns the generated path.
      #
      # @param username [String]
      # @param size [Integer]
      # @param cache [Boolean]
      # @param logger [Logger, nil]
      # @return [String] Filesystem path to the generated PNG.
      # @raise [ConfigurationError] If inputs/configuration are invalid.
      # @raise [ImageMagickError] If MiniMagick/ImageMagick fails to render.
      # @raise [FileSystemError] If the resulting file fails verification.
      # @raise [GenerationError] For other generation-related failures.
      def self.call(username, size, cache: true, logger: nil)
        new(username, size, cache: cache, logger: logger).execute!
      end

      # Run the avatar generation pipeline: build identity, resolve cache path,
      # and generate if needed.
      #
      # @return [String] Path to the generated (or cached) avatar PNG.
      # @raise [ConfigurationError] If inputs/configuration are invalid.
      # @raise [ImageMagickError] If MiniMagick/ImageMagick fails to render.
      # @raise [FileSystemError] Reserved for callers that optionally verify output.
      def execute!
        logger.info "Starting avatar generation for '#{username}' at size #{size}px"
        path = generate
        logger.info "Avatar generation completed successfully: #{path}"
        path
      rescue => e
        logger.error "Avatar generation failed: #{e.class.name} - #{e.message}"
        logger.error "Backtrace: #{e.backtrace.first(5).join("\n")}"
        raise
      end

      private

      attr_reader :username, :size, :cache, :font, :fill, :logger

      # Generate or reuse an avatar at the requested size.
      #
      # Builds an identity from `username`, computes the cache path,
      # renders the PNG if not already cached, and returns the file path.
      #
      # @return [String] Filesystem path to the generated or cached avatar PNG.
      def generate
        identity = build_identity
        target_size = normalize_size
        target_path = Avatar::Cache.path(identity, target_size)

        return use_cached(target_path) if cached?(target_path)

        generate_avatar(identity, target_size, target_path)

        target_path
      end

      # Build an avatar identity from the configured username.
      #
      # @return [Identity] Derived initials and background color.
      def build_identity
        Avatar::Identity.from_username(username).tap do |identity|
          logger.debug "Generated identity: #{identity.inspect}"
        end
      end

      # Clamp the requested size to the maximum full size.
      #
      # @return [Integer] Target size in pixels (<= {Avatar::FULLSIZE}).
      def normalize_size
        [size, Avatar::FULLSIZE].min.tap do |s|
          logger.debug "Target size: #{s}"
        end
      end

      # Check if a cached avatar exists at the given path.
      #
      # @param [String] path The expected avatar file path.
      # @return [Boolean] True if a cached file exists, false otherwise.
      def cached?(path)
        cache && File.exist?(path)
      end

      # Use an existing cached avatar path.
      #
      # @param [String] path The cached avatar file path.
      # @return [String] The same cached path that was provided.
      def use_cached(path)
        logger.info "Using cached avatar: #{path}"
        path
      end

      # Render the avatar image using MiniMagick/ImageMagick.
      #
      # @param identity [Identity] Letters and background color.
      # @param size [Integer] Target size in pixels.
      # @param filename [String, Pathname] Output file path.
      # @raise [ImageMagickError] If MiniMagick raises during conversion.
      def generate_avatar(identity, size, filename)
        MiniMagick.convert do |c|
          c.size "#{size}x#{size}"
          c << "xc:#{to_rgb(identity.color)}"
          c.pointsize NamePlate.pointsize.to_s
          c.font font.to_s
          c.weight NamePlate.weight.to_s
          c.fill fill.to_s.gsub(/\s+/, "")
          c.gravity "Center"
          c.annotate NamePlate.annotate_position.to_s, identity.letters.to_s
          c << filename.to_s
        end
      rescue => e
        raise ImageMagickError, "MiniMagick failed to generate avatar: #{e.message}"
      end

      # Convert `[r, g, b]` array to `rgb(r,g,b)` string accepted by ImageMagick.
      #
      # @param color [Array<Integer>] RGB values in the 0..255 range.
      # @return [String] `rgb(r,g,b)` formatted string.
      # @raise [ConfigurationError] If the color is not a valid triplet.
      def to_rgb(color)
        "rgb(#{color.join(",")})"
      rescue => e
        raise ConfigurationError, "Invalid color format: #{color.inspect} - #{e.message}"
      end

      # Validate constructor inputs and required configuration.
      #
      # @return [void]
      # @raise [ConfigurationError] When any validation fails.
      def validate_inputs!
        raise ConfigurationError, "Username cannot be empty" if username.to_s.strip.empty?
        raise ConfigurationError, "Size must be positive integer" unless size.is_a?(Integer) && size.positive?
        raise ConfigurationError, "Font file not found: #{font}" unless File.exist?(font.to_s)
        raise ConfigurationError, "Fill color not configured" if fill.to_s.empty?
      end

      # Build a default logger that writes to STDOUT.
      #
      # Log level defaults to `INFO`; set `ENV["NAMEPLATE_LOG_LEVEL"] = "DEBUG"`
      # to enable verbose output during generation.
      #
      # @return [Logger]
      def default_logger
        require "logger"
        Logger.new($stdout).tap do |log|
          log.level = (ENV["NAMEPLATE_LOG_LEVEL"]&.upcase == "DEBUG") ? Logger::DEBUG : Logger::INFO
          log.formatter = proc do |severity, datetime, _progname, msg|
            "[#{datetime.strftime("%H:%M:%S")}] #{severity}: #{msg}\n"
          end
        end
      end
    end
  end
end
