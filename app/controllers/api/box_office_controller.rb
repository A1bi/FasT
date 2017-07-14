class Api::BoxOfficeController < ApplicationController
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

    if date.event.seating.bound_to_seats?
      seating = NodeApi.seating_request("getChosenSeats", { clientId: info[:seatingId] }).body
      if !seating[:ok]
        response[:errors] << "Seating error"
        return render json: response
      end
      seats = seating[:seats]
    end

    info[:tickets].each do |type_id, number|
      ticket_type = Ticketing::TicketType.find_by_id(type_id)
      next if !ticket_type || number < 1

      if date.event.seating.bound_to_seats?
        seat = date.event.seating.seats.find(seats.shift)
      end

      number.times do
        order.tickets.new({
          type: ticket_type,
          seat: seat,
          date: date,
          picked_up: true
        })
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
    @order.cancel_tickets(@tickets, :cancellation_at_box_office)
    save_order_and_update_node_with_tickets(@order, @tickets)
    render json: { order: info_for_order(@order) }
  end

  def purchase
    purchase = Ticketing::BoxOffice::Purchase.new
    purchase.pay_method = params[:pay_method]
    tickets = []

    params[:items].each do |item|
      purchase_item = purchase.items.new
      case item[:type]
      when "ticket"
        ticket = Ticketing::Ticket.find(item[:id].to_i)
        purchase_item.purchasable = ticket
        purchase_item.number = 1
        tickets << ticket
      when "product"
        purchase_item.purchasable = Ticketing::BoxOffice::Product.find(item[:id].to_i)
        purchase_item.number = item[:number]
      when "order_payment"
        purchase_item.purchasable = Ticketing::BoxOffice::OrderPayment.new
        purchase_item.purchasable.order = Ticketing::Order.find(item[:order])
        purchase_item.purchasable.amount = item[:amount]
        purchase_item.number = 1
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
    end

    render json: { ok: ok }
  end

  def search
    ticket_id = nil
    orders = []
    if params[:q].present?
      if params[:q] =~ /\A(\d{7})(-(\d+))?\z/
        order = Ticketing::Order.where(number: $1).first
        orders << order
        if order && $3.present?
          ticket = order.tickets.where(order_index: $3).first
          ticket_id = ticket.id if ticket
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

    render json: {
      ticket_id: ticket_id.to_s,
      orders: orders.map { |o| info_for_order(o) }
    }
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
    NodeApi.seating_request("setExclusiveSeats", { clientId: params[:seating_id], seats: seats }) if seats.any?
    head :ok
  end

  def event
    event = Ticketing::Event.current

    response = {
      name: event.name,
      dates: event.dates.map { |date| { id: date.id.to_s, date: date.date.to_i } },
      ticket_types: Ticketing::TicketType.all.map { |type| { id: type.id.to_s, name: type.name, info: type.info || "", price: type.price || 0, exclusive: type.exclusive } },

      seats: event.seating.seats.map do |seat|
        { id: seat.id.to_s, block: { name: seat.block.name, color: seat.block.color }, row: seat.row.to_s, number: seat.number.to_s, grid: { x: seat.position_x, y: seat.position_y } }
      end,
      bound_to_seats: event.seating.bound_to_seats?
    }

    render :json => response
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
end
