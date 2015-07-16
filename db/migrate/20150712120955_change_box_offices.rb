class ChangeBoxOffices < ActiveRecord::Migration
  def change
    add_reference :ticketing_orders, :box_office
    add_column  :ticketing_box_office_purchases, :pay_method, :string
  end
end
