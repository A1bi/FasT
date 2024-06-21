# frozen_string_literal: true

module Ticketing
  class StripeRefundCreateService < StripeBaseService
    def execute
      raise 'Cannot create Stripe refund for order without credit' unless amount.positive?

      res = post('refunds', refund_body)
      refund = res.parsed_response
      create_transaction(refund)
    end

    private

    def refund_body
      {
        amount: stripe_formatted_amount,
        payment_intent: payment.id
      }
    end

    def payment
      @order.stripe_transactions.payments.first
    end

    def amount
      -super
    end
  end
end
