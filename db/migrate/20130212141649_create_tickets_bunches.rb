class CreateTicketsBunches < ActiveRecord::Migration
  def change
    create_table :tickets_bunches do |t|
      t.boolean :paid
      t.float :total
      t.integer :cencellation_id

      t.timestamps
    end
  end
end
