class AddInfoToTicketsTicketType < ActiveRecord::Migration
  def change
    add_column :tickets_ticket_types, :info, :string
  end
end
