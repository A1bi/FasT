class Api::OrdersController < ApplicationController
  def create
    info = params.require(:order)
    retailId = params[:retailId]
    type = (params[:type] || "").to_sym
    if type != :web && !((type == :admin && current_user&.admin?) || (type == :retail && cookies.signed["_#{Rails.application.class.parent_name}_retail_store_id"] == retailId))
      type = :web
    end

    order = (type == :retail ? Ticketing::Retail::Order : Ticketing::Web::Order).new
    order.admin_validations = true if type == :admin

    date = Ticketing::EventDate.find(info[:date])
    return render_error('Sold out') if date.sold_out? && type != :admin

    return render_error('Ticket sale currently disabled') if !current_user&.admin? && date.event.sale_disabled?

    bound_to_seats = date.event.seating.bound_to_seats?
    if bound_to_seats
      seats = NodeApi.get_chosen_seats(info[:socketId])
      return render_error('Seating error') if !seats
    end

    info[:tickets].each do |type_id, number|
      ticket_type = date.event.ticket_types.find_by(id: type_id)
      next if number < 1
      return render_error('Invalid ticket type') if !ticket_type

      credit_required = ticket_type.exclusive && type != :admin
      if credit_required && ticket_type.credit_left_for_member(current_user) < number
        return render_error('Not enough credit for exclusive ticket type')
      end

      number.times do
        ticket = order.tickets.new({
          type: ticket_type,
          date: date
        })
        ticket.seat = Ticketing::Seat.find(seats.shift) if bound_to_seats
      end

      next unless credit_required
      order.exclusive_ticket_type_credit_spendings.build(
        member: current_user,
        ticket_type: ticket_type,
        value: number
      )
    end

    tickets_by_price = order.tickets.to_a.sort_by{ |x| x.price }
    free_ticket_type = date.event.ticket_types.where(price: 0).first
    if info[:couponCodes].present? && info[:couponCodes].any?
      coupons = Ticketing::Coupon.where(code: info[:couponCodes])
      coupons.each do |coupon|
        next if coupon.expired?
        coupon.redeem
        order.coupons << coupon
        next if info[:ignore_free_tickets].present?

        coupon.free_tickets.times do
          break if tickets_by_price.empty?
          tickets_by_price.pop.type = free_ticket_type
          coupon.free_tickets = coupon.free_tickets - 1
        end
      end
    end

    if type != :retail
      order.attributes = info.require(:address).permit(:email, :first_name, :gender, :last_name, :affiliation, :phone, :plz)

      order.pay_method = (info[:payment] ||= {}).delete(:method)
      if order.charge_payment?
        order.build_bank_charge(info.require(:payment).permit(:name, :iban))
      end

    else
      order.store = Ticketing::Retail::Store.find_by_id(retailId)
    end

    ActiveRecord::Base.transaction do
      return render_error('Invalid order', errors: order.errors.messages) unless order.save

      if type == :web && params[:newsletter].present?
        subscriber = Newsletter::Subscriber.create(email: order.email, gender: order.gender, last_name: order.last_name, privacy_terms: true)
        subscriber.send_confirmation_instructions(after_order: true, delay: 30.minutes)
      end

      Ticketing::OrderPushNotificationsJob.perform_later(order, type: type.to_s)

      NodeApi.update_seats_from_records(order.tickets) if bound_to_seats

      if type == :admin
        key = "ticketing.orders.created"
        if order.email.present?
          key = key + "_email"
        end
        flash[:notice] = t(key)
      end

      render json: { order: order.api_hash(%i[tickets printable]) }
    end
  end

  private

  def render_error(error, extra = nil)
    Raven.capture_message(error, extra: extra)
    render status: :unprocessable_entity, json: { error: error }
  end
end
