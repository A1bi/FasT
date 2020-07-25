# frozen_string_literal: true

class CreateGbookEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :gbook_entries do |t|
      t.string :author
      t.text :text

      t.timestamps
    end
  end
end
