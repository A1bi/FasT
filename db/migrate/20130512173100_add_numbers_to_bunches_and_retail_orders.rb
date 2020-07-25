# frozen_string_literal: true

class AddNumbersToBunchesAndRetailOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_bunches, :number, :integer
    add_column :ticketing_retail_orders, :queue_number, :integer
  end
end
