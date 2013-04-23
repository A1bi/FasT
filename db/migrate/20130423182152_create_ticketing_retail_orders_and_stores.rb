class CreateTicketingRetailOrdersAndStores < ActiveRecord::Migration
  def change
    create_table :ticketing_retail_orders do |t|
      t.integer :store_id

      t.timestamps
    end
    
    create_table :ticketing_retail_stores do |t|
      t.string :name

      t.timestamps
    end
  end
end
