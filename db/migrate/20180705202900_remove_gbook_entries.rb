# frozen_string_literal: true

class RemoveGbookEntries < ActiveRecord::Migration[6.0]
  def up
    drop_table :gbook_entries
  end
end
