class ChangeTicketingOrdersPaid < ActiveRecord::Migration
  def up
    Ticketing::Order.where(paid: nil).update_all(paid: false)
    change_column :ticketing_orders, :paid, :boolean, default: false, null: false
  end
end
