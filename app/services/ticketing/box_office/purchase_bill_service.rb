# frozen_string_literal: true

module Ticketing
  module BoxOffice
    class PurchaseBillService
      attr_accessor :purchase

      def initialize(purchase)
        @purchase = purchase
      end

      def execute
        transfer_payment

        product_total = 0
        ticket_totals = {}
        ticket_totals.default = 0

        purchase.items.each do |item|
          purchasable = item.purchasable
          case purchasable
          when Product
            product_total += item.total
          when OrderPayment
            transfer_to_order(purchasable.order, purchasable.amount)
          when Ticketing::Ticket
            ticket_totals[purchasable.order] += purchasable.price
          end
        end

        purchase.withdraw_from_account(product_total, :purchased_products)

        transfer_to_orders(ticket_totals)
      end

      private

      def transfer_payment
        case purchase.pay_method
        when 'cash'
          purchase.transfer_to_account(purchase.box_office, -purchase.total, payment_note)
        when 'electronic_cash'
          purchase.deposit_into_account(purchase.total, payment_note)
        end
      end

      def transfer_to_orders(totals)
        totals.each do |order, total|
          transfer_to_order(order, total)
        end
      end

      def transfer_to_order(order, amount)
        note = if amount.negative?
                 :cash_refund_at_box_office
               else
                 payment_note
               end
        OrderBillingService.new(order)
                           .transfer_from_box_office_purchase(purchase, amount, note)
      end

      def payment_note
        @payment_note ||= case purchase.pay_method
                          when 'cash'
                            :cash_at_box_office
                          when 'electronic_cash'
                            :electronic_cash_at_box_office
                          end
      end
    end
  end
end
