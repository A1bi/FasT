class AddSaleStartToTicketingEvents < ActiveRecord::Migration
  def change
    add_column :ticketing_events, :sale_start, :datetime
  end
end
