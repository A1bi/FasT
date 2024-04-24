# frozen_string_literal: true

class Photo < ApplicationRecord
  include DelayedPostProcessing

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
        styles[:"#{name}_#{format}"] = [size, format]
      end
    end
  }

  delay_post_processing :image

  belongs_to :gallery

  validates_attachment :image, presence: true, content_type:
                         { content_type: %r{\Aimage/(jpe?g|png|hei[cf]|webp)\z} }

  before_save :set_dimensions

  private

  def set_dimensions
    return unless valid? && will_save_change_to_attribute?(:image_file_size)
    return if (file = image.queued_for_write[:original]).nil?

    geometry = Paperclip::Geometry.from_file(file)
    self.image_width = geometry.width
    self.image_height = geometry.height
  end
end
