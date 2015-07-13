class ChangeBoxOffices < ActiveRecord::Migration
  def change
    add_reference :ticketing_orders, :box_office
  end
end
