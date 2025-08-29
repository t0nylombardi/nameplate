# frozen_string_literal: true

module NamePlate
  class Avatar
    # Builds file paths for cached avatars.
    class Cache
      # Returns the base path for cached avatars.
      #
      # @return [String] Base cache path.
      def self.base_path
        "#{NamePlate.cache_base_path || "public/system"}/nameplate/#{Avatar::VERSION}"
      end

      # Builds the file path for a cached avatar.
      #
      # @param [Identity] identity The identity object representing the user.
      # @param [Integer] size The size of the avatar.
      # @return [String] The file path for the cached avatar.
      def self.path(identity, size)
        dir = File.join(base_path, identity.letters, identity.color.join("_"))
        FileUtils.mkdir_p(dir)
        File.join(dir, "#{size}.png")
      end

      # Check if a cached avatar exists for the given identity and size.
      #
      # @param [Identity] identity The identity object representing the user.
      # @param [Integer] size The size of the avatar.
      # @return [Boolean] True if a cached avatar exists, false otherwise.
      def self.cached?(identity, size)
        File.exist?(path(identity, size))
      end
    end
  end
end
