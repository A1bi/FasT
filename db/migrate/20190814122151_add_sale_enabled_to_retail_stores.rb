class AddSaleEnabledToRetailStores < ActiveRecord::Migration[5.2]
  def change
    add_column :ticketing_retail_stores, :sale_enabled, :boolean,
               null: false, default: false
  end
end
