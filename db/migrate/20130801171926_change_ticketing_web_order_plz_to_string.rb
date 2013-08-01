class ChangeTicketingWebOrderPlzToString < ActiveRecord::Migration
  def up
    change_column :ticketing_web_orders, :plz, :string
  end

  def down
    change_column :ticketing_web_orders, :plz, :integer
  end
end
