# frozen_string_literal: true

class AddAssignableToTicketsBunch < ActiveRecord::Migration[6.0]
  def change
    change_table :tickets_bunches, bulk: true do |t|
      t.integer :assignable_id
      t.string :assignable_type
    end
  end
end
