# frozen_string_literal: true

module Ticketing
  class OrderPaymentService
    def initialize(order, current_user: nil)
      @order = order
      @current_user = current_user
    end

    def mark_as_paid
      return if @order.cancelled? || @order.paid?

      billing_service.settle_balance(:payment_received)
      log_service.mark_as_paid
      @order.save

      send_email(:payment_received)
    end

    def send_reminder
      return unless @order.is_a?(Web::Order) && !@order.paid? && @order.email.present?

      send_email(:pay_reminder)
      @order.update(last_pay_reminder_sent_at: Time.current)
      log_service.send_pay_reminder
    end

    private

    def billing_service
      OrderBillingService.new(@order)
    end

    def send_email(action)
      OrderMailer.with(order: @order).public_send(action).deliver_later
    end

    def log_service
      LogEventCreateService.new(@order, current_user: @current_user)
    end
  end
end
