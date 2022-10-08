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
      deposit_into_account(-order_balance, note)
    end

    def settle_balance_with_bank_transaction(transaction = @order.open_bank_transaction)
      return if transaction.nil?

      transaction.amount -= order_balance
      transaction.save if transaction.persisted?
      settle_balance(order_balance.negative? ? :bank_charge_payment : :transfer_refund)
    end

    def settle_balance_with_retail_account(note = :cash_in_store)
      return unless @order.is_a? Retail::Order

      transfer_to_account(@order.store, order_balance, note)
    end

    def refund_in_retail_store
      return unless @order.billing_account.credit?

      settle_balance_with_retail_account(:cash_refund_in_store)
    end

    def adjust_balance(amount)
      deposit_into_account(amount, :correction)
    end

    def deposit_coupon_credit(coupon)
      return unless @order.billing_account.outstanding? &&
                    coupon.billing_account.credit?

      amount = [-coupon.value, order_balance].max
      transfer_to_account(coupon, amount, :redeemed_coupon)
    end

    def transfer_from_box_office_purchase(purchase, amount, note)
      transfer_to_account(purchase, -amount, note)
    end

    private

    def deposit_into_account(amount, note)
      @order.deposit_into_account(amount, note)
      update_paid
    end

    def transfer_to_account(recipient, amount, note)
      @order.transfer_to_account(recipient, amount, note)
      update_paid
    end

    def update_paid
      @order.update_paid
      @order.save if @order.persisted?
    end

    def order_balance
      @order.billing_account.balance
    end
  end
end
