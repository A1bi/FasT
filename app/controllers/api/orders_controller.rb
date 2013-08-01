class Api::OrdersController < ApplicationController
  cache_sweeper :ticket_sweeper, :only => [:create]
  cache_sweeper :order_sweeper, :only => [:create, :mark_as_paid]
  
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
    
    coupon_assignments = []
    if info[:couponCode].present?
      coupon = Ticketing::Coupon.where(code: info[:couponCode]).first
      order.bunch.coupon = coupon if !coupon.expired?
    end
    
		info[:tickets].each do |type_id, number|
      number = number.to_i
			type = Ticketing::TicketType.find_by_id(type_id)
      next if !type || number < 1
      
      if type.exclusive
        assignment = coupon.ticket_type_assignments.where(ticket_type_id: type).first
        next if !assignment
        if assignment.number >= 0
          assignment.number = assignment.number - number
          next if assignment.number < 0
        end
        coupon_assignments << assignment
      end
      
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
      if !isRetail && params[:newsletter].present?
        Newsletter::Subscriber.create(email: order.email)
      end
      
      seats = {}
      order.bunch.tickets.each do |ticket|
        seats.deep_merge! ticket.date_id => Hash[[ticket.seat.node_hash(ticket.date_id)]]
      end
      NodeApi.seating_request("updateSeats", { seats: seats })
      
      coupon_assignments.each { |a| a.save }
      
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
  
  def mark_as_paid
    order = Ticketing::Retail::Order.find(params[:id])
    order.mark_as_paid
    
    render :json => {
      ok: true
    }
  end
end
