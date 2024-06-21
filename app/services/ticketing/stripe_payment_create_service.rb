# frozen_string_literal: true

module Ticketing
  class StripePaymentCreateService < StripeBaseService
    def initialize(order, payment_method_id)
      super(order)
      @payment_method_id = payment_method_id
    end

    def execute
      raise 'Cannot create Stripe payment with negative amount' unless amount.positive?

      res = post('payment_intents', payment_body)
      payment = res.parsed_response
      method = payment.dig('charges', 'data', 0, 'payment_method_details', 'card', 'wallet', 'type')
      create_transaction(payment, method:)
    end

    private

    def payment_body
      {
        amount: stripe_formatted_amount,
        currency: 'eur',
        confirm: true,
        payment_method: @payment_method_id
      }
    end
  end
end
