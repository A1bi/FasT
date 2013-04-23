class Api::OrdersController < ApplicationController
  def create
    response = {
      ok: false,
      errors: []
    }
    
    info = params[:order]
    retailId = params[:retailId]
    
    order = ((retailId.present?) ? Ticketing::Retail::Order : Ticketing::Order).new
    
    order.build_bunch
		info[:tickets].each do |type_id, number|
      next if number < 1
			type = Ticketing::TicketType.find_by_id(type_id)
			number.to_i.times do
				ticket = Ticketing::Ticket.new
				ticket.type = type
				ticket.seat_id = info[:seats].shift
        ticket.date_id = info[:date]
        order.bunch.tickets << ticket
			end
		end
  
    if retailId.blank?
      order.attributes = info[:address]

      order.pay_method = (info[:payment] ||= {}).delete(:method)
      if order.pay_method == "charge"
        order.build_bank_charge(info[:payment])
      end
    
    else
      order.store = Ticketing::Retail::Store.find_by_id(retailId)
    end
    
    if !order.save
      response[:errors] << "Unknown error"
    end
    response[:ok] = true if response[:errors].empty?
    
    render :json => response
  end
end
