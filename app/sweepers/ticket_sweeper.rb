class TicketSweeper < ActionController::Caching::Sweeper
  observe Ticketing::Ticket
  
  def after_update(ticket)
    ["date_id", "price", "cancellation_id"].each do |attr|
      if ticket.send(attr + "_changed?")
        sweep_ticket_stats
        break
      end
    end
  end
  
  def after_create(ticket)
    sweep_ticket_stats
  end
  alias_method :after_destroy, :after_create
  
  def sweep_ticket_stats
    Rails.cache.delete([:ticketing, :statistics, :tickets])
    expire_fragment [:ticketing, :statistics, :tables]
    Rails.cache.delete([:ticketing, :statistics, :seats])
    expire_fragment [:ticketing, :statistics, :seats]
  end
end