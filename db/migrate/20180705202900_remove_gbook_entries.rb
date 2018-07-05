class RemoveGbookEntries < ActiveRecord::Migration[5.2]
  def up
    drop_table :gbook_entries
  end
end
