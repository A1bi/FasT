# frozen_string_literal: true

class Photo < ApplicationRecord
  SIZES = {
    small: 300,
    medium: 600,
    large: 900,
    x_large: 1600,
    xx_large: 3000
  }.freeze
  FORMATS = %i[webp jpeg].freeze

  has_attached_file :image, styles: {
    thumb: ['145x145#', :jpg],
    **FORMATS.each_with_object({}) do |format, styles|
      SIZES.each do |name, size|
        styles["#{name}_#{format}".to_sym] = [size, format]
      end
    end
  }

  validates_attachment :image, presence: true, content_type:
                         { content_type: %r{\Aimage/(jpe?g|png|hei[cf]|webp)\z} }

  belongs_to :gallery, touch: true
end
