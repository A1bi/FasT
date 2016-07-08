class CreateOrders < ActiveRecord::Migration
  def up
    create_table :ticketing_orders do |t|
      t.integer     :number
      t.boolean     :paid
      t.float       :total
      t.string      :email
      t.string      :first_name
      t.string      :last_name
      t.integer     :gender
      t.string      :phone
      t.string      :plz
      t.string      :pay_method
      t.references  :cancellation
      t.references  :coupon
      t.references  :store
      t.string      :type
      t.timestamps
    end
    rename_column :ticketing_tickets, :bunch_id, :order_id
    
    drop_table :ticketing_web_orders
    drop_table :ticketing_retail_orders
    drop_table :ticketing_bunches
  end
  
  def down
    create_table :ticketing_web_orders do |t|
      t.string   :email
      t.string   :first_name
      t.string   :last_name
      t.integer  :gender
      t.string   :phone
      t.string   :plz
      t.string   :pay_method
      t.timestamps
    end
    
    create_table :ticketing_retail_orders do |t|
      t.references :store
      t.integer    :queue_number
      t.timestamps
    end
    
    create_table :ticketing_bunches do |t|
      t.boolean     :paid
      t.float       :total
      t.references  :cancellation
      t.references  :assignable, polymorphic: true
      t.integer     :number
      t.references  :coupon
      t.timestamps
    end
    
    rename_column :ticketing_tickets, :order_id, :bunch_id
    drop_table :ticketing_orders
  end
end
