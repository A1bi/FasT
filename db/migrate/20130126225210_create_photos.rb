class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :text
      t.integer :pos
      t.integer :gallery_id

      t.timestamps
    end
  end
end
