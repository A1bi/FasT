class TicketsController < ApplicationController
	def new
		@event = Tickets::Event.current
		@seats = Tickets::Seat.order(:number)
		@ticket_types = Tickets::TicketType.order(:price)
  end
end
