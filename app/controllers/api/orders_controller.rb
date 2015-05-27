class Api::OrdersController < ApplicationController
  def create
    response = {
      ok: false,
      errors: []
    }
    
    info = params.require(:order)
    retailId = params[:retailId]
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
    
    if info[:couponCode].present?
      coupon = Ticketing::Coupon.where(code: info[:couponCode]).first
      coupon.orders << order if !coupon.expired?
    end
    
		info[:tickets].each do |type_id, number|
			ticket_type = Ticketing::TicketType.find_by_id(type_id)
      next if !ticket_type || number < 1
      
      if ticket_type.exclusive && (type != :admin || coupon)
        # assignment = coupon.ticket_type_assignments.where(ticket_type_id: ticket_type).first
        # workaround: autosave is not triggered when fetching the tickets like shown above
        assignment = coupon.ticket_type_assignments.find do |a|
          a.ticket_type_id == ticket_type.id
        end
        puts assignment
        next if !assignment
        if assignment.number >= 0
          assignment.number = assignment.number - number
          next if assignment.number < 0
        end
      end
      
      number.times do
        order.tickets.new({
          type: ticket_type,
          seat: Ticketing::Seat.find(seats.shift),
          date: Ticketing::EventDate.find(info[:date])
        })
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
      if order.save
        begin
          if type == :web && params[:newsletter].present?
            Newsletter::Subscriber.create(email: order.email, gender: order.gender, last_name: order.last_name)
          end
          
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
          
        rescue
          response[:errors] << "Internal error"
          raise ActiveRecord::Rollback
        end
      else
        puts order.errors.messages
        response[:errors] << "Invalid order"
      end
    end
    
    render json: response
  end
end
