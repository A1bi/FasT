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

  private

  def find_box_office
    @box_office = Ticketing::BoxOffice::BoxOffice.first
  end
end
