class SeatSweeper < ActionController::Caching::Sweeper
  observe Ticketing::Seat, Ticketing::Block, Ticketing::Reservation
  
  def after_update(record)
    if record.is_a? Ticketing::Seat
      ["position_x", "position_y"].each do |attr|
        if ticket.send(attr + "_changed?")
          sweep_seating_caches
          break
        end
      end
    end
  end
  
  def after_create(record)
    sweep_seating_caches
  end
  alias_method :after_destroy, :after_create
  
  def sweep_seating_caches
    Rails.cache.delete([:ticketing, :statistics, :seats])
    expire_fragment [:ticketing, :statistics, :seats]
    expire_fragment [:new_order, :seats]
  end
end