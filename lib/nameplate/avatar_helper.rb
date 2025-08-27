# frozen_string_literal: true

module NamePlate
  module AvatarHelper
    def nameplate_for(name, size = 64)
      NamePlate.generate(name, size)
    end

    def nameplate_url_for(avatar_path)
      NamePlate.path_to_url(avatar_path)
    end

    def nameplate_url(name, size = 64)
      nameplate_url_for(nameplate_for(name, size))
    end

    def nameplate_tag(name, size = 64, options = {})
      if defined?(ActionView::Helpers::AssetTagHelper)
        extend ActionView::Helpers::AssetTagHelper
        image_tag(nameplate_url(name, size), options.merge(alt: name))
      else
        "<img alt=\"#{name}\" class\"#{options.fetch(:class)}\" src=\"#{nameplate_url(name, size)}\" />"
      end
    end
  end
end
