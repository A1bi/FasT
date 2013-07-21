class Api::OrdersController < ApplicationController
  cache_sweeper :ticket_sweeper, :only => [:create]
  cache_sweeper :order_sweeper, :only => [:create, :mark_paid]
  
  def create
    response = {
      ok: false,
      errors: []
    }
    
    info = params[:order]
    retailId = params[:retailId]
    
    isRetail = retailId.present?
    order = (isRetail ? Ticketing::Retail::Order : Ticketing::Web::Order).new
    
    order.build_bunch
    
    if retailId.present? && params[:web]
      order.omit_queue_number = true
      order.bunch.paid = true
    end
    
    seating = NodeApi.seating_request("getChosenSeats", { clientId: info[:seatingId] }).body
    if !seating[:ok]
      response[:errors] << "Seating error"
      return render :json => response
    end
    seats = seating[:seats]
    
		info[:tickets].each do |type_id, number|
      number = number.to_i
      next if number < 1
			type = Ticketing::TicketType.find_by_id(type_id)
			number.times do
				ticket = Ticketing::Ticket.new
				ticket.type = type
				ticket.seat_id = seats.shift
        ticket.date_id = info[:date]
        order.bunch.tickets << ticket
			end
		end
  
    if !isRetail
      order.attributes = info[:address]

      order.pay_method = (info[:payment] ||= {}).delete(:method)
      if order.pay_method == "charge"
        order.build_bank_charge(info[:payment])
      end
    
    else
      order.store = Ticketing::Retail::Store.find_by_id(retailId)
    end
    
    if order.save
      if !isRetail && info[:newsletter].present?
        Newsletter::Subscriber.create(email: order.email)
      end
      
      seats = {}
      order.bunch.tickets.each do |ticket|
        (seats[ticket.date_id] ||= {})[ticket.seat.id] = ticket.seat.node_hash(ticket.date_id)
      end
      NodeApi.seating_request("updateSeats", { seats: seats })
      
      response[:ok] = true
      response[:order] = order.api_hash
    else
      response[:errors] << "Unknown error"
    end
    
    render :json => response
  end
  
  def retail
    orders = Ticketing::Retail::Order.by_store(params[:store_id]).api_hash
    
    render :json => orders
  end
  
  def mark_paid
    order = Ticketing::Retail::Order.find(params[:id])
    order.mark_as_paid
    
    render :json => {
      ok: true
    }
  end
end
