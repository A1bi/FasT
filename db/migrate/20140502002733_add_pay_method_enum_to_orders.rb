class AddPayMethodEnumToOrders < ActiveRecord::Migration
  def up
    methods = Ticketing::Web::Order.pay_methods.keys
    Ticketing::Web::Order.all.each do |order|
      method = nil
      if methods.include?(order[:pay_method])
        method = Ticketing::Web::Order.pay_methods[order[:pay_method]]
      end
      order.update_attribute(:pay_method, method)
    end
    
    change_column :ticketing_orders, :pay_method, :integer
  end
  
  def down
    change_column :ticketing_orders, :pay_method, :string
  end
end
