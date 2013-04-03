class Api::OrdersController < ApplicationController
  def create
    info = params[:order]
    
    order = Tickets::Order.new
    order.build_bunch
    
		info[:numbers].each do |type_id, number|
			type = Tickets::TicketType.find_by_id(type_id)
			number.to_i.times do
				ticket = order.bunch.tickets.build
				ticket.type = type
				ticket.reservation = Tickets::Reservation.first
			end
		end
    
    order.attributes = info[:address]
    
    response = {
      ok: false,
      errors: {}
    }
    if order.save
      response[:ok] = true
    else
      response[:errors][:general] = "Unknown error"
    end
    
    render :json => response
  end
end
