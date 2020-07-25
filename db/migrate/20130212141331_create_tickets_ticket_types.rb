# frozen_string_literal: true

class CreateTicketsTicketTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets_ticket_types do |t|
      t.string :name
      t.float :price

      t.timestamps
    end
  end
end
