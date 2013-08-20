class Api::OrdersController < ApplicationController
  def create
    response = {
      ok: false,
      errors: []
    }
    
    info = params[:order]
    retailId = params[:retailId]
    if retailId.present?
      type = :retail
    else
      type = (params[:type] || "").to_sym
      type = :web if type == :service && !@_member.admin?
    end
    
    order = (type == :retail ? Ticketing::Retail::Order : Ticketing::Web::Order).new
    order.service_validations = true if type == :service
    
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
			ticket_type = Ticketing::TicketType.find_by_id(type_id)
      next if !ticket_type || number < 1
      
      if ticket_type.exclusive && type != :service
        assignment = coupon.ticket_type_assignments.where(ticket_type_id: ticket_type).first
        next if !assignment
        if assignment.number >= 0
          assignment.number = assignment.number - number
          next if assignment.number < 0
        end
        coupon_assignments << assignment
      end
      
      number.times do
				ticket = Ticketing::Ticket.new
				ticket.type = ticket_type
				ticket.seat = Ticketing::Seat.find(seats.shift)
        ticket.date = Ticketing::EventDate.find(info[:date])
        order.bunch.tickets << ticket
			end
		end
  
    if type != :retail
      order.attributes = info[:address]

      order.pay_method = (info[:payment] ||= {}).delete(:method)
      if order.pay_method == "charge"
        order.build_bank_charge(info[:payment])
      end
    
    else
      order.store = Ticketing::Retail::Store.find_by_id(retailId)
    end
    
    if order.save
      if type == :web && params[:newsletter].present?
        Newsletter::Subscriber.create(email: order.email)
      end
      
      seats = {}
      order.bunch.tickets.each do |ticket|
        seats.deep_merge! ticket.date_id => Hash[[ticket.seat.node_hash(ticket.date_id)]]
      end
      NodeApi.update_seats(seats)
      
      coupon_assignments.each { |a| a.save }
      
      response[:ok] = true
      response[:order] = order.api_hash
    else
      response[:errors] << "Unknown error"
    end
    
    render :json => response
  end
  
  def retail
    orders = Ticketing::Retail::Order.by_store(params[:store_id]).includes(:bunch).where(:ticketing_bunches => { :cancellation_id => nil }).api_hash
    
    render :json => orders
  end
  
  def current_date
    orders = Ticketing::Web::Order.includes(bunch: [:tickets]).where(:ticketing_bunches => { :cancellation_id => nil }).order(:last_name, :first_name).all.map { |o| { id: o.id.to_s, number: o.bunch.number.to_s, last_name: o.last_name, first_name: o.first_name, number_of_tickets: o.bunch.tickets.count } }
    
    render :json => { ok: true, orders: orders }
  end
  
  def by_number
    order = Ticketing::Bunch.includes(:assignable).where(number: params[:number]).first.assignable
    
    render :json => { ok: true, order: order.api_hash(true) }
  end
  
  def mark_as_paid
    order = Ticketing::Retail::Order.find(params[:id])
    order.mark_as_paid
    
    render :json => {
      ok: true
    }
  end
end
