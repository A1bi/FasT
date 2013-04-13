class Api::OrdersController < ApplicationController
  def create
    info = params[:order]
    
    order = Ticketing::Order.new
    order.build_bunch
    
		info[:tickets].each do |type_id, number|
			type = Ticketing::TicketType.find_by_id(type_id)
			number.to_i.times do
				ticket = Ticketing::Ticket.new
				ticket.type = type
				ticket.seat_id = info[:seats].shift
        ticket.date_id = info[:date]
        order.bunch.tickets << ticket
			end
		end
    
    order.attributes = info[:address]
    
    order.pay_method = info[:payment].delete(:method)
    if order.pay_method == "charge"
      order.build_bank_charge(info[:payment])
    end
    
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
