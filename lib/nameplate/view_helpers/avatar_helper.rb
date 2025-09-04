# frozen_string_literal: true

require "action_view"
require "action_view/helpers"

module NamePlate
  module ViewHelpers
    # Rails view helpers for rendering avatars in controllers/views.
    #
    # Usage in Rails:
    #   include NamePlate::ViewHelpers::Avatar
    #
    # Then in your views:
    #   nameplate_for("Tony", 200)
    #   nameplate_url("Tony", 200)
    #   nameplate_tag("Tony", 200, class: "avatar")
    module AvatarHelper
      if defined?(ActionView::Helpers::AssetTagHelper)
        include ActionView::Helpers::AssetTagHelper
      end

      # Return path to generated avatar image
      #
      # @param name [String] the name to base avatar on
      # @param size [Integer] requested size in px
      # @return [String] filesystem path
      def nameplate_for(name, size = 64)
        NamePlate::Avatar.generate(name, size)
      end

      # Return URL for generated avatar image
      #
      # @param name [String] the name to base avatar on
      # @param size [Integer] requested size in px
      # @return [String] URL path
      def nameplate_url(name, size = 64)
        NamePlate.path_to_url(nameplate_for(name, size))
      end

      # Render an <img> tag for the avatar
      #
      # @param name [String] the name to base avatar on
      # @param size [Integer] requested size
      # @param options [Hash] HTML options (e.g., :class)
      # @return [String] HTML img tag
      def nameplate_tag(name, size = 64, options = {})
        src = nameplate_url(name, size)

        if defined?(ActionView::Helpers::AssetTagHelper)
          extend ActionView::Helpers::AssetTagHelper
          image_tag(src, options.merge(alt: name))
        else
          class_attr = options.fetch(:class, nil)
          class_str = class_attr ? %( class="#{class_attr}") : ""
          %(<img alt="#{name}"#{class_str} src="#{src}" />)
        end
      end
    end
  end
end
