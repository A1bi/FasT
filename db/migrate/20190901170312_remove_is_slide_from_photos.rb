# frozen_string_literal: true

class RemoveIsSlideFromPhotos < ActiveRecord::Migration[6.0]
  def change
    remove_column :photos, :is_slide, :boolean

    reversible do |dir|
      dir.up do
        Photo.find_each do |photo|
          photo.image.clear(:slide)
          photo.save
        end
      end
    end
  end
end
