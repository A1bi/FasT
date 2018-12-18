class AddNameToTicketingSeatings < ActiveRecord::Migration[5.2]
  def change
    add_column :ticketing_seatings, :name, :string
  end
end
