# frozen_string_literal: true

module Ticketing
  class OrderPaymentService
    def initialize(order)
      @order = order
    end

    def mark_as_paid
      return if @order.cancelled? || @order.paid?

      @order.withdraw_from_account(@order.billing_account.balance,
                                   :payment_received)
      @order.log(:marked_as_paid)
      @order.save

      send_email(:payment_received)
    end

    def send_reminder
      return unless web_order? && !@order.paid?

      @order.log(:sent_pay_reminder).save

      send_email(:pay_reminder)
    end

    private

    def send_email(action)
      return unless web_order?

      Ticketing::OrderMailer.with(order: @order)
                            .public_send(action).deliver_later
    end

    def web_order?
      @order.is_a?(Ticketing::Web::Order)
    end
  end
end
