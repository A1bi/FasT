class TicketsController < ApplicationController
	before_filter :find_event, :only => [:new]
	before_filter :prepare_ajax_response, :only => [:seats, :reserve_seat]
	before_filter :find_date, :only => [:seats, :reserve_seat]
	
  def new
		@seats = Tickets::Seat.order(:number)
		@ticket_types = Tickets::TicketType.order(:price)
  end
	
	def seats
		@response[:seats] = []
		Tickets::Seat.includes_reserved_on_date(@date).each do |seat|
			@response[:seats] << {
				id: seat.id,
				available: !seat.reserved
			}
		end
		
		send_ajax_response
	end
	
	def reserve_seat
		seat = Tickets::Seat.find(params[:id])
		if seat.nil?
			error_ajax_response(l("tickets.seat_not_found"))
		else
			@response[:seat] = seat.id
			if seat.reserve_on_date(@date).nil?
				error_ajax_response(l("tickets.seat_taken"))
			end
		end
		
		send_ajax_response
	end
	
	private
	
	def find_event
		@event = Tickets::Event.last
	end
	
	def find_date
		@date = Tickets::EventDate.find(params[:date])
		if @date.nil?
			error_ajax_response(l("tickets.date_not_found"))
			return send_ajax_response
		end
	end
	
	def prepare_ajax_response
		@response = {
			ok: true,
			error: ""
		}
	end
	
	def send_ajax_response
		render :json => @response
	end
	
	def error_ajax_response(error)
		@response[:ok] = false
		@response[:error] = error
	end
end
