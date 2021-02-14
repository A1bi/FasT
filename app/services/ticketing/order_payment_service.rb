# frozen_string_literal: true

module Ticketing
  class OrderPaymentService
    def initialize(order, current_user: nil)
      @order = order
      @current_user = current_user
    end

    def approve_charge
      return unless web_order? && @order.charge_payment? &&
                    !@order.bank_charge.approved

      @order.bank_charge.update(approved: true)
      log_service.approve
    end

    def mark_as_paid
      return if @order.cancelled? || @order.paid?

      @order.withdraw_from_account(@order.billing_account.balance,
                                   :payment_received)
      log_service.mark_as_paid
      @order.save

      send_email(:payment_received)
    end

    def send_reminder
      return unless web_order? && !@order.paid?

      send_email(:pay_reminder)
      log_service.send_pay_reminder
    end

    private

    def send_email(action)
      OrderMailer.with(order: @order).public_send(action).deliver_later
    end

    def log_service
      LogEventCreateService.new(@order, current_user: @current_user)
    end

    def web_order?
      @order.is_a?(Web::Order)
    end
  end
end
