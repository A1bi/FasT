class Api::BoxOfficeController < ApplicationController
  ignore_authenticity_token

  before_action :find_box_office, only: :purchase

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

  def events
    events = Ticketing::Event.current.map do |event|
      {
        id: event.id.to_s,
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

  private

  def find_box_office
    @box_office = Ticketing::BoxOffice::BoxOffice.first
  end
end
