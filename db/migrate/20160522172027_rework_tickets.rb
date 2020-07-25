# frozen_string_literal: true

class ReworkTickets < ActiveRecord::Migration[6.0]
  def change
    remove_column :ticketing_tickets, :number, :integer

    change_table :ticketing_tickets, bulk: true do |t|
      t.integer :order_index, null: false, default: 0
      t.index %i[order_id order_index], unique: true
    end
  rescue ActiveRecord::RecordNotUnique
    raise 'error: all existing tickets have to be destroyed first'
  end
end
