# frozen_string_literal: true

module Ticketing
  class OrderBillingService
    def initialize(order)
      @order = order
    end

    def update_balance(note)
      old_total = @order.total
      yield
      @order.update_total
      diff = old_total - @order.total
      deposit_into_account(diff, note)
    end

    def settle_balance(note)
      deposit_into_account(-@order.billing_account.balance, note)
    end

    private

    def deposit_into_account(amount, note)
      @order.deposit_into_account(amount, note)
      @order.update_paid
      @order.save
    end
  end
end
