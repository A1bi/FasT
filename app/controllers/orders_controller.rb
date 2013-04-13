class OrdersController < ApplicationController
	def new
		@event = Ticketing::Event.current
		@seats = Ticketing::Seat.order(:number)
		@ticket_types = Ticketing::TicketType.order(:price)
  end
end
