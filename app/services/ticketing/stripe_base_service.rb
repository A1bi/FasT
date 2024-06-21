# frozen_string_literal: true

module Ticketing
  class StripeBaseService
    include HTTParty

    class TransactionError < StandardError; end

    base_uri 'https://api.stripe.com'

    def initialize(order)
      @order = order
    end

    private

    def post(resource, body = {})
      response = self.class.post("/v1/#{resource}", basic_auth: auth, body:)
      raise_transaction_error(response:) unless response.success?

      response
    end

    def create_transaction(object, additional_attributes = {})
      transaction = @order.stripe_transactions.build(
        type: object['object'],
        stripe_id: object['id'],
        amount: object['amount'].to_f / 100,
        **additional_attributes
      )
      transaction.save! if @order.persisted?
      transaction
    end

    def amount
      -@order.balance
    end

    def stripe_formatted_amount
      (amount * 100).to_i
    end

    def raise_transaction_error(extra = {})
      Sentry.capture_message('Stripe transaction failed', extra:)

      raise TransactionError
    end

    def auth
      { username: private_key }
    end

    def private_key
      Rails.application.credentials.stripe[Rails.env.production? ? :live : :test].private_key
    end
  end
end
