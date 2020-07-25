# frozen_string_literal: true

class CreateGalleries < ActiveRecord::Migration[6.0]
  def change
    create_table :galleries do |t|
      t.string :title
      t.string :disclaimer
      t.integer :pos

      t.timestamps
    end
  end
end
