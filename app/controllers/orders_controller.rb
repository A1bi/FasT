class OrdersController < ApplicationController
  before_filter :disable_slides
  
	def new
		@event = Ticketing::Event.current
		@seats = Ticketing::Seat.order(:number)
		@ticket_types = Ticketing::TicketType.order(:price)
  end
end
