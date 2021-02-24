# frozen_string_literal: true

module Ticketing
  class OrderPaymentService
    def initialize(order, current_user: nil)
      @order = order
      @current_user = current_user
    end

    def approve_charge
      return unless charge? && !@order.bank_charge.approved

      @order.bank_charge.update(approved: true)
      log_service.approve
    end

    def submit_charge
      return unless charge? && @order.bank_charge.approved &&
                    !@order.bank_charge.submitted?

      @order.bank_charge.amount = -@order.billing_account.balance
      billing_service.settle_balance(:bank_charge_submitted)
      log_service.submit_charge
      @order.save
    end

    def mark_as_paid
      return if @order.cancelled? || @order.paid?

      billing_service.settle_balance(:payment_received)
      log_service.mark_as_paid
      @order.save

      send_email(:payment_received)
    end

    def send_reminder
      return unless web_order? && !@order.paid?

      send_email(:pay_reminder)
      log_service.send_pay_reminder
    end

    def refund_in_retail_store
      return unless retail_order? && @order.billing_account.credit?

      billing_service.settle_balance_with_retail_account(:cash_refund_in_store)
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

    def charge?
      web_order? && @order.charge_payment?
    end

    def web_order?
      @order.is_a?(Web::Order)
    end

    def retail_order?
      @order.is_a?(Retail::Order)
    end
  end
end
