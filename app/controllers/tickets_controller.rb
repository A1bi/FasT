class TicketsController < ApplicationController
	before_filter :prepare_ajax_response, :only => [:update_order]
	
  def new
		@event = Tickets::Event.current
		@seats = Tickets::Seat.order(:number)
		@ticket_types = Tickets::TicketType.order(:price)
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
	
	private
	
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
