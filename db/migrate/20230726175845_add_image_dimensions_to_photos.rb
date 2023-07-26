# frozen_string_literal: true

class AddImageDimensionsToPhotos < ActiveRecord::Migration[7.0]
  def change
    %i[width height].each do |column|
      add_column :photos, "image_#{column}", :smallint
    end
  end
end
