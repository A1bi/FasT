# frozen_string_literal: true

class AddSaleDisabledMessageToTicketingEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_events, :sale_disabled_message, :string
  end
end
