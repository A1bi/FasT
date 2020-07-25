# frozen_string_literal: true

class AddIsSlideToPhotos < ActiveRecord::Migration[6.0]
  def change
    add_column :photos, :is_slide, :boolean, default: false
  end
end
