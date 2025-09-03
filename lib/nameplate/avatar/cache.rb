# frozen_string_literal: true

require "concurrent-ruby"
require "fileutils"

module NamePlate
  class Avatar
    # Thread-safe cache manager for avatar file paths.
    class Cache
      @cache = Concurrent::Map.new

      class << self
        # Returns the base path for cached avatars.
        #
        # @return [String] Base cache path.
        def base_path
          "#{NamePlate.cache_base_path || "public/system"}/nameplate/#{Avatar::VERSION}"
        end

        # Builds or fetches the file path for a cached avatar.
        #
        # Uses a Concurrent::Map to ensure thread-safe memoization.
        #
        # @param [Identity] identity The identity object representing the user.
        # @param [Integer] size The size of the avatar.
        # @return [String] The file path for the cached avatar.
        def path(identity, size)
          key = cache_key(identity, size)

          @cache.compute_if_absent(key) do
            dir = File.join(base_path, identity.letters, identity.color.join("_"))
            FileUtils.mkdir_p(dir)
            File.join(dir, "#{size}.png")
          end
        end

        # Check if a cached avatar exists for the given identity and size.
        #
        # @param [Identity] identity The identity object representing the user.
        # @param [Integer] size The size of the avatar.
        # @return [Boolean] True if a cached avatar exists, false otherwise.
        def cached?(identity, size)
          File.exist?(path(identity, size))
        end

        private

        # Builds a unique cache key from identity + size.
        #
        # @param [Identity] identity
        # @param [Integer] size
        # @return [String]
        def cache_key(identity, size)
          "#{identity.letters}-#{identity.color.join("_")}-#{size}"
        end
      end
    end
  end
end
