class TicketsController < ApplicationController
	before_filter :prepare_ajax_response, :only => [:seats, :reserve_seat, :update_order, :order_info]
	before_filter :check_date, :only => [:seats, :reserve_seat]
	
  def new
		@event = Tickets::Event.last
		@seats = Tickets::Seat.order(:number)
		@ticket_types = Tickets::TicketType.order(:price)
  end
	
	def order_info
		@response[:order] = {
			step: session[:order][:step],
			info: session[:order][:info]
		}
		
		send_ajax_response
	end
	
	def update_order
		params[:order] ||= {}
		params[:order][:info] ||= {}

		order_info = session[:order] ||= { step: nil, info: {}, reservations: [] }
		current_step = order_info[:step] = params[:order][:step].to_sym
		order_info[:info][current_step] = params[:order][:info]
		order_info[:info][current_step] = params[:order][:info][:tickets_order] if current_step == :address
		
		order = prepared_order
		
		case current_step
		when :address
			order.validate_address
			if !order.errors.empty?
				error_ajax_response(order.errors.messages)
			end
		when :confirm
			if !order.valid?
				error_ajax_response({ general: "invalid info" })
			else
				order.save
				order_info = nil
			end
		end
		
		send_ajax_response
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
		order = prepared_order
		
		seat = Tickets::Seat.find(params[:id])
		if seat.nil?
			error_ajax_response({ seats: t("tickets.errors.seat_not_found") })
		else
			@response[:seat] = seat.id
			reservation = seat.reserve_on_date(@date)
			if reservation.nil?
				error_ajax_response({ seats: t("tickets.errors.seat_taken") })
			else
				(session[:order][:reservations] ||= []) << reservation.id
			end
		end
		
		send_ajax_response
	end
	
	
	private
	
	def check_date
		date_id = session.try(:[], :order).try(:[], :info).try(:[], :date).try(:[], :date)
		if !date_id
			error_ajax_response({ seats: "date not set yet" })
			return send_ajax_response
		else
			@date = Tickets::EventDate.find(date_id)
			if @date.nil?
				error_ajax_response({ seats: t("tickets.date_not_found") })
				return send_ajax_response
			end
		end
	end
	
	def prepared_order
		# remove expired reservations
		session[:order][:reservations].delete_if do |reservation_id|
			!Tickets::Reservation.exists?(reservation_id)
		end
		
		order = Tickets::Order.new
		order.update_info(session[:order])
		order
	end
	
	def prepare_ajax_response
		@response = {
			ok: true,
			errors: {}
		}
	end
	
	def send_ajax_response
		render :json => @response
	end
	
	def error_ajax_response(errors)
		@response[:ok] = false
		@response[:errors].update(errors)
	end
end
