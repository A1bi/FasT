class Api::BoxOfficeController < ApplicationController
  ignore_authenticity_token

  before_action :find_tickets, only: [:ticket_printable, :pick_up_tickets]
  before_action :find_tickets_with_order, only: [:cancel_tickets, :enable_resale_for_tickets]
  before_action :find_box_office, only: [:place_order, :purchase, :report, :bill]

  def place_order
    response = {
      ok: false,
      errors: []
    }

    info = params.require(:order)
    order = Ticketing::BoxOffice::Order.new
    order.box_office = @box_office

    date = Ticketing::EventDate.find(info[:date])

    bound_to_seats = date.event.seating.bound_to_seats?
    if bound_to_seats
      seats = NodeApi.get_chosen_seats(info[:seatingId])
      if !seats
        response[:errors] << "Seating error"
        return render json: response
      end
    end

    info[:tickets].each do |type_id, number|
      ticket_type = Ticketing::TicketType.find_by_id(type_id)
      next if !ticket_type || number < 1

      number.times do
        ticket = order.tickets.new({
          type: ticket_type,
          date: date,
          picked_up: true
        })
        ticket.seat = date.event.seating.seats.find(seats.shift) if bound_to_seats
      end
    end

    ActiveRecord::Base.transaction do
      if order.save
        begin
          if date.event.seating.bound_to_seats?
            NodeApi.update_seats_from_records(order.tickets)
          end

          response[:ok] = true
          response[:order] = info_for_order(order)

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

  def cancel_order
    order = Ticketing::BoxOffice::Order.find_by_id(params[:id])
    if order
      tickets = order.tickets.to_a
      order.destroy
      NodeApi.update_seats_from_records(tickets)
    end
    render json: {}
  end

  def cancel_tickets
    @order.cancel_tickets(@tickets, :cancellation_at_box_office, false)
    save_order_and_update_node_with_tickets(@order, @tickets)
    render json: { order: info_for_order(@order) }
  end

  def purchase
    purchase = Ticketing::BoxOffice::Purchase.new
    purchase.pay_method = params[:pay_method]
    tickets = []
    orders = []

    params[:items].each do |item|
      purchase_item = purchase.items.new
      case item[:type]
      when "ticket"
        ticket = Ticketing::Ticket.find(item[:id].to_i)
        purchase_item.purchasable = ticket
        purchase_item.number = 1
        tickets << ticket
        orders << ticket.order
      when "product"
        purchase_item.purchasable = Ticketing::BoxOffice::Product.find(item[:id].to_i)
        purchase_item.number = item[:number]
      when "order_payment"
        order = Ticketing::Order.find(item[:order])
        purchase_item.purchasable = Ticketing::BoxOffice::OrderPayment.new
        purchase_item.purchasable.order = order
        purchase_item.purchasable.amount = item[:amount]
        purchase_item.number = 1
        orders << order
      end
    end

    @box_office.purchases << purchase

    ok = false
    if @box_office.save
      ok = true
      tickets.each do |ticket|
        ticket.picked_up = true
        ticket.save
      end
      orders.uniq.each(&:save)
    end

    render json: { ok: ok }
  end

  def search
    ticket = nil
    orders = nil
    if params[:q].present?
      max_digits = Ticketing::Order::NUMBER_DIGITS
      ticket_number_regex = Regexp.new(/\A(\d{1,#{max_digits}})(-(\d+))?\z/)
      if params[:q] =~ ticket_number_regex
        orders = Ticketing::Order.where(number: Regexp.last_match(1))
        if orders.any? && Regexp.last_match(3).present?
          ticket = orders.first.tickets.find_by_order_index(Regexp.last_match(3))
        end

      else
        table = Ticketing::Order.arel_table
        matches = nil
        (params[:q] + " " + ActiveSupport::Inflector.transliterate(params[:q])).split(" ").uniq.each do |term|
          match = table[:first_name].matches("%#{term}%").or(table[:last_name].matches("%#{term}%"))
          matches = matches ? matches.or(match) : match
        end
        orders = Ticketing::Order.where(matches).order(:last_name, :first_name)
      end
    end

    render_orders(orders, ticket)
  end

  def order_show
    order = Ticketing::Order.find(params[:id])
    render json: {
      order: info_for_order(order)
    }
  end

  def todays
    orders = Ticketing::Order
             .unpaid
             .joins(tickets: :date)
             .where(
               ticketing_tickets: {
                 cancellation_id: nil
               },
               ticketing_event_dates: {
                 date: Date.today.all_day
               }
             )
             .order(:last_name, :first_name)
             .distinct

    render_orders(orders)
  end

  def ticket_printable
    pdf = TicketsBoxOfficePDF.new
    pdf.add_tickets(@tickets)
    send_data pdf.render, type: "application/pdf", disposition: "inline"
  end

  def pick_up_tickets
    @tickets.update_all(picked_up: true)
    render json: {}
  end

  def enable_resale_for_tickets
    @order.enable_resale_for_tickets(@tickets)
    save_order_and_update_node_with_tickets(@order, @tickets)
    render json: { order: info_for_order(@order) }
  end

  def unlock_seats
    seats = {}
    Ticketing::ReservationGroup.where.not(id: 8).each do |reservation_group|
      reservation_group.reservations.each do |reservation|
        (seats[reservation.date.id] ||= []) << reservation.seat.id
      end
    end
    NodeApi.seating_request("setExclusiveSeats", { seats: seats }, params[:seating_id]) if seats.any?
    head :ok
  end

  def events
    events = Ticketing::Event.current.map do |event|
      {
        id: event.id,
        name: event.name,
        dates: event.dates.map do |date|
          {
            id: date.id.to_s,
            date: date.date.to_i
          }
        end,
        ticket_types: event.ticket_types.map do |type|
          {
            id: type.id.to_s,
            name: type.name,
            info: type.info || '',
            price: type.price || 0,
            exclusive: type.exclusive
          }
        end,
        bound_to_seats: event.seating.bound_to_seats?,
        seats: event.seating.seats.map do |seat|
          {
            id: seat.id.to_s,
            block_name: seat.block.name,
            row: seat.row.to_s,
            number: seat.number.to_s
          }
        end
      }
    end

    render json: { events: events }
  end

  def products
    render json: {
      products: Ticketing::BoxOffice::Product.all.map do |product|
        {
          id: product.id,
          name: product.name,
          price: product.price
        }
      end
    }
  end

  def report
    response = {}

    start_date = 12.hours.ago

    response[:products] = @box_office
      .purchases
      .where("ticketing_box_office_purchases.created_at > ?", start_date)
      .includes(:items)
      .where("ticketing_box_office_purchase_items.purchasable_type = 'Ticketing::BoxOffice::Product'")
      .group("ticketing_box_office_purchase_items.purchasable_id")
      .sum("ticketing_box_office_purchase_items.number")
      .map do |item_id, number|
        {
          name: Ticketing::BoxOffice::Product.find(item_id).name,
          number: number
        }
    end

    response[:billings] = @box_office
      .billing_account
      .transfers
      .where("created_at > ?", start_date)
      .map do |transfer|
        {
          reason: t("ticketing.orders.balancing." + transfer.note_key.to_s, default: transfer.note_key.to_s),
          amount: transfer.amount,
          date: transfer.created_at.to_i
        }
    end

    response[:balance] = @box_office.billing_account.balance

    render json: response
  end

  def bill
    @box_office.billing_account.deposit(params[:amount], params[:reason])
    @box_office.billing_account.save
    render json: { ok: true }
  end

  private

  def find_tickets
    @tickets = Ticketing::Ticket.where(id: params[:ticket_ids])
  end

  def find_tickets_with_order
    @order = Ticketing::Ticket.find(params[:ticket_ids].first).order

    # @tickets = order.tickets.cancelled(false).find(params[:ticket_ids])
    # workaround: autosave is not triggered when fetching the tickets like shown above
    @tickets = @order.tickets.select do |ticket|
      params[:ticket_ids].include?(ticket.id.to_s) && !ticket.cancelled?
    end
  end

  def find_box_office
    @box_office = Ticketing::BoxOffice::BoxOffice.first
  end

  def save_order_and_update_node_with_tickets(order, tickets)
    if order.save
      NodeApi.update_seats_from_records(tickets)
    end
  end

  def info_for_order(order)
    order.api_hash([:personal, :log_events, :tickets, :status, :billing], [:status])
  end

  def render_orders(orders, ticket = nil)
    render json: {
      ticket_id: ticket&.id&.to_s,
      orders: orders.map { |o| info_for_order(o) }
    }
  end
end
