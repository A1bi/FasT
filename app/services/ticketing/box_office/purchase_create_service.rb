module Ticketing
  module BoxOffice
    class PurchaseCreateService
      attr_accessor :params, :current_box_office

      def initialize(params, current_box_office)
        @params = params
        @current_box_office = current_box_office
      end

      def execute
        purchase = Ticketing::BoxOffice::Purchase.new(
          box_office: current_box_office,
          pay_method: params[:pay_method]
        )

        @orders = []

        params[:items].each do |item_info|
          item = purchase.items.new

          case item_info[:type]
          when 'ticket'
            add_ticket(item_info, item)
          when 'product'
            add_product(item_info, item)
          when 'order_payment'
            add_order(item_info, item)
          end
        end

        return purchase unless purchase.save

        @orders.uniq.each(&:save)

        purchase
      end

      private

      def add_ticket(item_info, item)
        ticket = Ticketing::Ticket.find(item_info[:id].to_i)
        ticket.update(picked_up: true)
        item.purchasable = ticket
        item.number = 1
        @orders << ticket.order
      end

      def add_product(item_info, item)
        item.purchasable = Ticketing::BoxOffice::Product.find(item_info[:id].to_i)
        item.number = item_info[:number]
      end

      def add_order(item_info, item)
        order = Ticketing::Order.find(item_info[:order])
        item.purchasable = Ticketing::BoxOffice::OrderPayment.new
        item.purchasable.order = order
        item.purchasable.amount = item_info[:amount]
        item.number = 1
        @orders << order
      end
    end
  end
end
