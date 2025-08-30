# frozen_string_literal: true

module NamePlate
  # Mixin for models that "have an avatar".
  #
  # Example:
  #   class User
  #     include NamePlate::HasAvatar
  #     attr_accessor :name
  #   end
  #
  #   user = User.new.tap { |u| u.name = "Tony" }
  #   user.avatar_path(128)
  #   # => "public/system/nameplate/2/T/226_95_81/128.png"
  #
  module HasAvatar
    # Return the filesystem path to the generated avatar
    #
    # @param size [Integer] size in px (default 64)
    # @return [String] path to avatar image
    def avatar_path(size = 64)
      NamePlate::Avatar.generate(username, size)
    end

    # Return the URL path to the generated avatar
    #
    # @param size [Integer] size in px (default 64)
    # @return [String] URL for avatar image
    def avatar_url(size = 64)
      NamePlate.path_to_url(avatar_path(size))
    end
  end
end
