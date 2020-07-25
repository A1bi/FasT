# frozen_string_literal: true

class AddSaleEnabledToRetailStores < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_retail_stores, :sale_enabled, :boolean,
               null: false, default: false
  end
end
