# frozen_string_literal: true

class AddPayMethodEnumToOrders < ActiveRecord::Migration[6.0]
  def up
    change_column :ticketing_orders, :pay_method, :integer, using: 0
  end

  def down
    change_column :ticketing_orders, :pay_method, :string, using: 'transfer'
  end
end
