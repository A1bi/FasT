class TicketsController < ApplicationController
	before_filter :find_event
	
  def new
		@seats = Tickets::Seat.order(:number)
		@ticket_types = Tickets::TicketType.order(:price)
  end
	
	def seats
		response = [];
		
		Tickets::Seat.includes_reserved_on_date(params[:date]).each do |seat|
			response << {
				id: seat.id,
				available: !seat.reserved
			}
		end
		
		render :json => response
	end
	
	private
	
	def find_event
		@event = Tickets::Event.last
	end
end
