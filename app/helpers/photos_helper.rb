# frozen_string_literal: true

module PhotosHelper
  def full_width_photo_tags(photo, class: nil, alt: '', data: nil, loading: 'eager')
    photo_tags(photo, 12, fallback_size: :x_large_jpeg, class:, alt:, data:, loading:)
  end

  def photo_tags(photo, columns, fallback_size:, class: nil, alt: '', data: nil, loading: 'eager')
    tag.picture class:, data: do
      capture do
        concat photo_source_tags(photo, columns)
        concat tag.img(src: photo.image.url(fallback_size), alt:, loading:)
      end
    end
  end

  def photo_source_tags(photo, columns)
    width_on_device = "#{columns * 100 / 12}vw"
    capture do
      %i[webp jpeg].each do |format|
        concat tag.source(srcset: photo_srcset(photo, format), sizes: width_on_device, type: "image/#{format}")
      end
    end
  end

  private

  def photo_srcset(photo, format)
    %i[small medium large x_large xx_large].map do |size|
      style = "#{size}_#{format}".to_sym
      "#{photo.image.url(style)} #{photo.image.styles[style][:geometry]}w"
    end.join(', ')
  end
end
