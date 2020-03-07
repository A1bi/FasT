# frozen_string_literal: true

json.photos @photos do |photo|
  json.call(photo, :id, :text)
  json.url do
    json.big photo.image.url(:big)
    json.full gallery_photo_path(@gallery, photo) if policy(photo).show?
  end
end
