class CreateGbookEntries < ActiveRecord::Migration
  def change
    create_table :gbook_entries do |t|
      t.string :author
      t.text :text

      t.timestamps
    end
  end
end
