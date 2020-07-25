# frozen_string_literal: true

class AddSaleStartToTicketingEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_events, :sale_start, :datetime
  end
end
