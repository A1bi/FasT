class AddPayMethodEnumToOrders < ActiveRecord::Migration
  def up    
    change_column :ticketing_orders, :pay_method, :integer
  end
  
  def down
    change_column :ticketing_orders, :pay_method, :string
  end
end
