class CreateOrders < ActiveRecord::Migration
  def copy_attrs(attrs, target, source)
    attrs.each { |attr| target[attr] = source[attr] }
  end
  
  def up
    ActiveRecord::Base.record_timestamps = false
    ActionMailer::Base.delivery_method = :test
    
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
    
    bunch_attrs = %i(paid total number cancellation_id coupon_id created_at updated_at)
    web_attrs = %i(email first_name last_name gender phone plz pay_method)
    classes = { "Ticketing::Web::Order" => :ticketing_web_orders, "Ticketing::Retail::Order" => :ticketing_retail_orders }
    
    tickets = exec_query("SELECT * FROM ticketing_tickets")
    
    exec_query("SELECT * FROM ticketing_bunches").each do |bunch|
      bunch.symbolize_keys!
      next if bunch[:assignable_type].empty?
      
      order = bunch[:assignable_type].constantize.new
      copy_attrs bunch_attrs, order, bunch
      
      old_order = exec_query("SELECT * FROM #{classes[bunch[:assignable_type]]} WHERE id = #{bunch[:assignable_id]}").first.symbolize_keys
      if old_order.present?
        if bunch[:assignable_type] == "Ticketing::Web::Order"
          copy_attrs web_attrs, order, old_order
        else
          order.store_id = old_order[:store_id]
        end
      end
      
      order.save(validate: false)
      
      tickets.each do |ticket|
        ticket.symbolize_keys!
        if ticket[:order_id] == bunch[:id]
          execute("UPDATE ticketing_tickets SET order_id = #{order.id} WHERE id = #{ticket[:id]}")
        end
      end
      
      execute("UPDATE ticketing_bank_charges SET chargeable_id = #{order.id}, chargeable_type = 'Ticketing::Order' WHERE chargeable_type = 'Ticketing::Web::Order' AND chargeable_id = #{old_order[:id]}")
      execute("UPDATE ticketing_log_events SET loggable_id = #{order.id}, loggable_type = 'Ticketing::Order' WHERE loggable_type = 'Ticketing::Bunch' AND loggable_id = #{bunch[:id]}")
      execute("UPDATE ticketing_box_office_purchase_items SET purchasable_id = #{order.id}, purchasable_type = 'Ticketing::Order' WHERE purchasable_type = 'Ticketing::Bunch' AND purchasable_id = #{bunch[:id]}")
    end
    
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
