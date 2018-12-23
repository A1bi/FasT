class AddSaleDisabledMessageToTicketingEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :ticketing_events, :sale_disabled_message, :string
  end
end
