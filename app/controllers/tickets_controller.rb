class TicketsController < ApplicationController
	before_filter :find_event
	
  def new
		@ticket_types = Tickets::TicketType.order(:price)
  end
	
	private
	
	def find_event
		@event = Tickets::Event.last
	end
end
