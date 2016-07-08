class AddPaidToTicketingTickets < ActiveRecord::Migration
  def change
    add_column :ticketing_tickets, :paid, :boolean, default: false
  end
  
  def migrate(direction)
    super
    if direction == :up
      change_column :members_dates, :info, :text, limit: nil
    end
  end
end
