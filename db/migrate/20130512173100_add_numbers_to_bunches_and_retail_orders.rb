class AddNumbersToBunchesAndRetailOrders < ActiveRecord::Migration
  def change
    add_column :ticketing_bunches, :number, :integer
    add_column :ticketing_retail_orders, :queue_number, :integer
  end
end
