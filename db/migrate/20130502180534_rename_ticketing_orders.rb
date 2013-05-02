class RenameTicketingOrders < ActiveRecord::Migration
  def change
    rename_table :ticketing_orders, :ticketing_web_orders
  end
end
