class CreateGalleries < ActiveRecord::Migration
  def change
    create_table :galleries do |t|
      t.string :title
      t.string :disclaimer
      t.integer :pos

      t.timestamps
    end
  end
end
