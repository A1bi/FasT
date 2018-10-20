class AddDateToTicketingOrders < ActiveRecord::Migration[5.2]
  def change
    add_reference :ticketing_orders, :date

    reversible do |dir|
      dir.up do
        Ticketing::Order.find_each(&:save)
      end
    end
  end
end
