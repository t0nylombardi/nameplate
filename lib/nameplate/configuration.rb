# frozen_string_literal: true

module NamePlate
  module Configuration
    def cache_base_path
      @cache_base_path
    end

    def cache_base_path=(v)
      @cache_base_path = v
    end

    def font
      @font || Avatar::FONT_FILENAME
    end

    def font=(v)
      @font = v
    end

    def fill_color
      @fill_color || Avatar::FILL_COLOR
    end

    def fill_color=(v)
      @fill_color = v
    end

    def colors_palette
      @colors_palette ||= :google
    end

    def colors_palette=(v)
      @colors_palette = v if Colors::Palette.include?(v)
    end

    def custom_palette
      @custom_palette ||= nil
    end

    def custom_palette=(v)
      @custom_palette = v
      if @custom_palette.nil? && @colors_palette == :custom
        raise "Missing Custom Palette, please set config.custom_palette if using :custom"
      end
      if Colors.valid_custom_palette?(@custom_palette)
        raise "Invalid Custom Palette, please update config.custom_palette"
      end
    end

    def weight
      @weight ||= 300
    end

    def weight=(v)
      @weight = v
    end

    def annotate_position
      @annotate_position ||= "-0+5"
    end

    def annotate_position=(v)
      @annotate_position = v
    end

    def letters_count
      @letters_count ||= 1
    end

    def letters_count=(v)
      @letters_count = v
    end

    def pointsize
      @pointsize ||= 140
    end

    def pointsize=(v)
      @pointsize = v
    end
  end
end
