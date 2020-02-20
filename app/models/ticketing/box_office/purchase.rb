module Ticketing
  module BoxOffice
    class Purchase < BaseModel
      include Ticketing::Billable

      belongs_to :box_office
      has_many :items, class_name: 'PurchaseItem', dependent: :destroy

      validates :items, length: { minimum: 1 }

      before_validation :update_total
      before_create :bill

      def total
        self[:total] || 0
      end

      private

      def bill
        case pay_method
        when 'cash'
          order_payment_note = :cash_at_box_office
          transfer_to_account(box_office, -total, order_payment_note)
        when 'electronic_cash'
          order_payment_note = :electronic_cash_at_box_office
          deposit_into_account(total, order_payment_note)
        end

        product_total = 0
        ticket_totals = {}
        items.each do |item|
          purchasable = item.purchasable
          case purchasable
          when Product
            product_total += item.total
          when OrderPayment
            note = if purchasable.amount.negative?
                     :cash_refund_at_box_office
                   else
                     order_payment_note
                   end
            transfer_to_account(purchasable.order, purchasable.amount, note)
          when Ticketing::Ticket
            ticket_totals[purchasable.order] =
              (ticket_totals[purchasable.order] || 0) + purchasable.price
          end
        end

        withdraw_from_account(product_total, :purchased_products)

        ticket_totals.each do |order, total|
          transfer_to_account(order, total, order_payment_note)
        end
      end

      def update_total
        self[:total] = 0
        items.each do |item|
          self[:total] = item.total.to_f + total.to_f
        end
      end
    end
  end
end
