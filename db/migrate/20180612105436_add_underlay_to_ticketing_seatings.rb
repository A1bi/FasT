# frozen_string_literal: true

class AddUnderlayToTicketingSeatings < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_seatings, :underlay_filename, :string
  end
end
