class ChangeBoxOffices < ActiveRecord::Migration
  def change
    add_reference :ticketing_orders, :box_office
    add_column  :ticketing_box_office_purchases, :pay_method, :string
    
    create_table :ticketing_box_office_refunds do |t|
      t.decimal :amount, default: 0, null: false
      t.belongs_to :order
      
      t.timestamps
    end
  end
end
