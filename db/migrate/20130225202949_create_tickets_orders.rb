class CreateTicketsOrders < ActiveRecord::Migration
  def change
    create_table :tickets_orders do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.integer :gender
      t.string :phone
      t.integer :plz

      t.timestamps
    end
  end
end
