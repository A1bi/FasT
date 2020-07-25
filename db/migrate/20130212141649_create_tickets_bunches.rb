# frozen_string_literal: true

class CreateTicketsBunches < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets_bunches do |t|
      t.boolean :paid
      t.float :total
      t.integer :cencellation_id

      t.timestamps
    end
  end
end
