# frozen_string_literal: true

module NamePlate
  module HasAvatar
    def self.included(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module ClassMethods
    end

    module InstanceMethods
      def self.included(base)
        base.extend ClassMethods
      end

      def avatar_path(size = 64)
        NamePlate.generate(name, size)
      end

      def avatar_url(size = 64)
        NamePlate.path_to_url(avatar_path(size))
      end

    end
  end
end
