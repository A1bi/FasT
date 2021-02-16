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
      @order.deposit_into_account(diff, note)
      @order.save
    end

    def settle_balance(note)
      @order.withdraw_from_account(@order.billing_account.balance, note)
      @order.save
    end
  end
end
