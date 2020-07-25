# frozen_string_literal: true

class AddNameToTicketingSeatings < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_seatings, :name, :string
  end
end
