# frozen_string_literal: true

module Ticketing
  class StripeTransaction < ApplicationRecord
    self.inheritance_column = nil

    belongs_to :order

    enum :type, %i[payment_intent refund]
    enum :method, %i[apple_pay google_pay]

    validates :type, :stripe_id, :amount, presence: true
    validates :method, presence: true, if: :payment_intent?
    validates :amount, numericality: { other_than: 0 }

    class << self
      def payments
        where(type: 'payment_intent')
      end
    end

    def method
      return super if payment_intent? || super.present?

      order.stripe_transactions.payment_intent.first&.method
    end
  end
end
