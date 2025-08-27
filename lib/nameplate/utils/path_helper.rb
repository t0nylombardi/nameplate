module Utils
  module PathHelper
    module_function

    # Convert a public file-system path to a URL path.
    #
    # @param path [String, Pathname]
    # @return [String]
    #
    # Examples:
    #   PathHelper.path_to_url("public/avatars/a.png") #=> "/avatars/a.png"
    def path_to_url(path)
      path.to_s.sub(%r{\Apublic/}, "/")
    end
  end
end
