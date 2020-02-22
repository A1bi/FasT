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
        purchase.items.each do |item|
          purchasable = item.purchasable
          case purchasable
          when Product
            product_total += item.total
          when OrderPayment
            note = if purchasable.amount.negative?
                     :cash_refund_at_box_office
                   else
                     payment_note
                   end
            transfer_to_account(purchasable.order, purchasable.amount, note)
          when Ticketing::Ticket
            ticket_totals[purchasable.order] =
              (ticket_totals[purchasable.order] || 0) + purchasable.price
          end
        end

        purchase.withdraw_from_account(product_total, :purchased_products)

        ticket_totals.each do |order, total|
          transfer_to_account(order, total, payment_note)
        end
      end

      private

      def transfer_payment
        case purchase.pay_method
        when 'cash'
          transfer_to_account(purchase.box_office, -purchase.total,
                              payment_note)
        when 'electronic_cash'
          purchase.deposit_into_account(purchase.total, payment_note)
        end
      end

      def transfer_to_account(account, amount, note)
        purchase.transfer_to_account(account, amount, note)
      end

      def payment_note
        @payment_note ||= begin
          case purchase.pay_method
          when 'cash'
            :cash_at_box_office
          when 'electronic_cash'
            :electronic_cash_at_box_office
          end
        end
      end
    end
  end
end
