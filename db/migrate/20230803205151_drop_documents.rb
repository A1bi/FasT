# frozen_string_literal: true

class DropDocuments < ActiveRecord::Migration[7.0]
  def change
    drop_table :documents do |t|
      t.string :title
      t.string :description
      t.timestamps
      t.attachment :file
      t.integer :members_group, default: 0, index: true
    end
  end
end
