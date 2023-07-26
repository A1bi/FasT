# frozen_string_literal: true

namespace :one_off do
  task run: :environment do
    Photo.where(image_width: nil).find_each do |photo|
      geometry = Paperclip::Geometry.from_file(photo.image)
      photo.update(
        image_width: geometry.width,
        image_height: geometry.height
      )
    end
  end
end
