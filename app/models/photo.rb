# frozen_string_literal: true

class Photo < ApplicationRecord
  has_attached_file :image, styles: {
    thumb: ['145x145#', :jpg],
    **%i[webp jpeg].each_with_object({}) do |format, styles|
      %i[small medium large].each.with_index(1) do |size, i|
        styles["#{size}_#{format}".to_sym] = [300 * i, format]
      end
    end
  }

  validates_attachment :image, presence: true, content_type:
                         { content_type: %r{\Aimage/(jpe?g|png|hei[cf]|webp)\z} }

  belongs_to :gallery, touch: true
end
