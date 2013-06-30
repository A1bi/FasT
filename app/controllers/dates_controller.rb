class DatesController < ApplicationController
  def jedermann
    @event = Ticketing::Event.current
    @ticket_types = Ticketing::TicketType.order(:id)
  end
end
