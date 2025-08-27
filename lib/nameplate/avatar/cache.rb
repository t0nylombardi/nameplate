# frozen_string_literal: true

module NamePlate
  module Avatar
    # Builds file paths for cached avatars.
    class Cache
      # @return [String] base cache path
      def self.base_path
        "#{NamePlate.cache_base_path || "public/system"}/letter_avatars/#{Avatar::VERSION}"
      end

      # @param identity [Identity]
      # @param size [Integer]
      # @return [String] file path for the cached avatar
      def self.path(identity, size)
        dir = File.join(base_path, identity.letters, identity.color.join("_"))
        FileUtils.mkdir_p(dir)
        File.join(dir, "#{size}.png")
      end

      # @param identity [Identity]
      # @return [String] path to fullsize avatar
      def self.fullsize_path(identity)
        path(identity, Avatar::FULLSIZE)
      end
    end
  end
end
