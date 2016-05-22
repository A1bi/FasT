class ReworkTickets < ActiveRecord::Migration
  def change
    begin
      change_table :ticketing_tickets do |t|
        t.remove :number, :integer
        t.integer :order_index, null: false, default: 0
        t.index [:order_id, :order_index], unique: true
      end
      
    rescue
      raise "error: all existing tickets have to be destroyed first"
    end
  end
end
