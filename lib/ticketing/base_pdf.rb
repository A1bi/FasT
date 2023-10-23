# frozen_string_literal: true

# rubocop:disable Rails/DotSeparatedKeys
module Ticketing
  class BasePdf < Prawn::Document
    include ActionView::Helpers::NumberHelper

    FONTS = [
      {
        name: 'Maven',
        file_prefix: 'maven-pro-v32-latin',
        styles: %i[normal bold],
        styles_mapping: { normal: :regular, bold: '900' }
      },
      {
        name: 'Lora',
        file_prefix: 'lora-v32-latin',
        styles: %i[bold_italic],
        styles_mapping: { bold_italic: '700italic' }
      }
    ].freeze
    FONT_SIZES = { normal: 14, small: 11, tiny: 8 }.freeze

    FG_COLOR = '000000'
    BG_COLOR = 'ffffff'

    def initialize(margin: nil, page_size: nil, page_layout: nil)
      @stamps = {}

      super page_size:, page_layout:, margin:,
            info: {
              Title: t(:title),
              Author: t(:author, scope: :base_pdf),
              Creator: t(:creator, scope: :base_pdf),
              CreationDate: Time.current
            }

      fill_color self.class::FG_COLOR
      stroke_color self.class::FG_COLOR

      fonts = FONTS.each_with_object({}) do |font, f|
        f[font[:name]] = font[:styles].index_with do |style|
          style = font[:styles_mapping][style]
          assets_path.join('fonts', "#{font[:file_prefix]}-#{style}.ttf").to_s
        end
      end
      font_families.update(fonts)
      font FONTS[0][:name]

      fill_background
    end

    private

    def stamp_name(key, record)
      "#{key}_#{record ? record.id : 'default'}"
    end

    def create_stamp(key, record, &)
      if (@stamps[key] ||= {})[record].nil?
        outer_start = y
        float do
          start = cursor
          super(stamp_name(key, record), &)
          height = start - cursor

          @stamps[key][record] = [outer_start, height]
        end
      end

      @stamps[key][record]
    end

    def draw_stamp(key, record, offset, &)
      start, height = create_stamp(key, record, &)
      stamp_at(stamp_name(key, record), [0, offset ? y - start : 0])
      move_down height
    end

    def font_size_name(size)
      font_size(FONT_SIZES[size]) { yield if block_given? }
    end

    def fill_background
      save_graphics_state do
        canvas do
          fill_color BG_COLOR
          fill_rectangle [0, bounds.height], bounds.width, bounds.height
        end
      end
    end

    def t(key, options = {})
      options[:scope] ||= i18n_scope
      I18n.t(key, **options)
    end

    def l(date, options = {})
      I18n.l(date, **options)
    end

    def svg_image(path, options)
      file = File.read(images_path.join(path))
      svg file, options
    end

    def assets_path
      Rails.root.join('app/assets')
    end

    def images_path
      assets_path.join('images')
    end
  end
end
# rubocop:enable Rails/DotSeparatedKeys
