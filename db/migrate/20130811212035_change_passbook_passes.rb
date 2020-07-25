# frozen_string_literal: true

class ChangePassbookPasses < ActiveRecord::Migration[6.0]
  def change
    change_table :passbook_passes, bulk: true do |t|
      t.integer :assignable_id
      t.string :assignable_type
      t.rename :path, :filename
    end
  end
end
