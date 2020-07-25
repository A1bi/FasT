# frozen_string_literal: true

class AddImageToPhotos < ActiveRecord::Migration[6.0]
  def change
    add_attachment :photos, :image
  end
end
