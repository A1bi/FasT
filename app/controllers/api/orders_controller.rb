class Api::OrdersController < ApplicationController
  def create
    response = {
      ok: false,
      errors: []
    }
    
    info = params.require(:order)
    retailId = params[:retailId].to_i
    type = (params[:type] || "").to_sym
    if type != :web && !((type == :admin && @_member.admin?) || (type == :retail && cookies.signed["_#{Rails.application.class.parent_name}_retail_store_id"] == retailId))
      type = :web
    end
    
    order = (type == :retail ? Ticketing::Retail::Order : Ticketing::Web::Order).new
    order.admin_validations = true if type == :admin
    
    seating = NodeApi.seating_request("getChosenSeats", { clientId: info[:seatingId] }).body
    if !seating[:ok]
      response[:errors] << "Seating error"
      return render json: response
    end
    seats = seating[:seats]
    
    coupon_assignments = []
    if info[:couponCode].present?
      coupon = Ticketing::Coupon.where(code: info[:couponCode]).first
      coupon.orders << order if !coupon.expired?
    end
    
		info[:tickets].each do |type_id, number|
      number = number.to_i
			ticket_type = Ticketing::TicketType.find_by_id(type_id)
      next if !ticket_type || number < 1
      
      if ticket_type.exclusive && (type != :admin || coupon)
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
        order.tickets << ticket
			end
		end
  
    if type != :retail
      order.attributes = info.require(:address).permit(:email, :first_name, :gender, :last_name, :phone, :plz)

      order.pay_method = (info[:payment] ||= {}).delete(:method)
      if order.charge?
        order.build_bank_charge(info.require(:payment).permit(:name, :iban))
      end
    
    else
      order.store = Ticketing::Retail::Store.find_by_id(retailId)
    end
    
    ActiveRecord::Base.transaction do
      begin
        if order.save
          if type == :web && params[:newsletter].present?
            Newsletter::Subscriber.create(email: order.email, gender: order.gender, last_name: order.last_name)
          end
          
          coupon_assignments.each { |a| a.save }
          
          options = { scope: "ticketing.push_notifications.tickets_sold", count: order.tickets.count }
          options[:store] = order.store.name if type == :retail
          Ticketing::PushNotifications::Device.push(:stats, {
            aps: {
              alert: t(type, options),
              badge: Ticketing::Ticket.where("created_at >= ?", Time.zone.now.beginning_of_day).count,
              sound: "cash.aif"
            }
          })
          
          order.send_confirmation if type == :web
          
          NodeApi.update_seats_from_tickets(order.tickets)
    
          response[:ok] = true
          response[:order] = order.api_hash([:tickets, :printable])
        else
          response[:errors] << "Invalid order"
        end
      rescue
        response[:errors] << "Internal error"
        raise ActiveRecord::Rollback
      end
    end
    
    render json: response
  end
end
