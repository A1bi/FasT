class DatesController < ApplicationController
  def jedermann
    @event = Ticketing::Event.current
    @ticket_types = Ticketing::TicketType.exclusive(false).order("price DESC")
  end
end
