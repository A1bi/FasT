# frozen_string_literal: true

class AddContactInfoToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :street
      t.integer :plz
      t.string :city
      t.string :phone
      t.date :joined_at
    end
  end
end
