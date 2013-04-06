class CreateTicketsBankCharges < ActiveRecord::Migration
  def change
    create_table :tickets_bank_charges do |t|
      t.string :name
      t.integer :number
      t.integer :blz
      t.string :bank
      t.string :chargeable_type
      t.integer :chargeable_id

      t.timestamps
    end
    
    add_column :tickets_orders, :pay_method, :string
  end
end
