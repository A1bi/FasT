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

    def settle_balance_with_retail_account(note = :cash_in_store)
      return unless @order.is_a? Retail::Order

      @order.transfer_to_account(@order.store, @order.billing_account.balance,
                                 note)
      update_paid
    end

    def refund_in_retail_store
      return unless @order.billing_account.credit?

      settle_balance_with_retail_account(:cash_refund_in_store)
    end

    def adjust_balance(amount)
      deposit_into_account(amount, :correction)
    end

    private

    def deposit_into_account(amount, note)
      @order.deposit_into_account(amount, note)
      update_paid
    end

    def update_paid
      @order.update_paid
      @order.save
    end
  end
end
