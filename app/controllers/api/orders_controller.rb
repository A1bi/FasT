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
    
    date = Ticketing::EventDate.find(info[:date])
    if date.sold_out?
      response[:errors] << "Sold out"
      return render json: response
    end
    
    bound_to_seats = date.event.seating.bound_to_seats?
    if bound_to_seats
      seating = NodeApi.seating_request("getChosenSeats", { clientId: info[:seatingId] }).body
      if !seating[:ok]
        response[:errors] << "Seating error"
        return render json: response
      end
      seats = seating[:seats]
    end
    
    if info[:couponCodes].present? && info[:couponCodes].any?
      coupons = Ticketing::Coupon.where(code: info[:couponCodes]).to_a
      coupons.select! do |coupon|
        if !coupon.expired?
          coupon.redeem
          order.coupons << coupon
          true
        end
      end
    end
    
		info[:tickets].each do |type_id, number|
			ticket_type = Ticketing::TicketType.find_by_id(type_id)
      next if !ticket_type || number < 1
      
      if ticket_type.exclusive
        remaining = number
        
        (coupons ||= []).each do |coupon|
          # assignment = coupon.ticket_type_assignments.where(ticket_type_id: ticket_type).first
          # workaround: autosave is not triggered when fetching the tickets like shown above
          assignment = coupon.ticket_type_assignments.find do |a|
            a.ticket_type_id == ticket_type.id
          end
          next if !assignment
          
          diff = assignment.number - remaining
          assignment.number = [0, diff].max
          remaining = -diff
          break if diff >= 0
        end
        
        if remaining > 0 && type != :admin
          response[:errors] << "Coupon error"
          return render json: response
        end
      end
      
      number.times do
        ticket = order.tickets.new({
          type: ticket_type,
          date: date
        })
        ticket.seat = Ticketing::Seat.find(seats.shift) if bound_to_seats
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
          aps = {
            alert: t(type, options),
            badge: Ticketing::Ticket.where("created_at >= ?", Time.zone.now.beginning_of_day).count
          }
          Ticketing::PushNotifications::Device.where(app: :stats).each do |device|
            payload = {
              aps: aps
            }
            payload[:aps][:sound] = "cash.aif" if device.settings[:sound_enabled]
            device.push(payload)
          end
          
          NodeApi.update_seats_from_records(order.tickets) if bound_to_seats
          
          if type == :admin
            key = "ticketing.orders.created"
            if order.email.present?
              key = key + "_email"
            end
            flash[:notice] = t(key)
          end
    
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
