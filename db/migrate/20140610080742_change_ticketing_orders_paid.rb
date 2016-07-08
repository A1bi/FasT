class ChangeTicketingOrdersPaid < ActiveRecord::Migration
  def up
    change_column :ticketing_orders, :paid, :boolean, default: false, null: false
  end
end
