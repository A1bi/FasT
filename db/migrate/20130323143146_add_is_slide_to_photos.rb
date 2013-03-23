class AddIsSlideToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :is_slide, :boolean, :default => false
  end
end
