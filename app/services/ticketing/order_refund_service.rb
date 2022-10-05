# frozen_string_literal: true

module Ticketing
  class OrderRefundService
    def initialize(order)
      @order = order
    end

    def execute(params)
      @params = params
      return unless @order.billing_account.credit? && bank_transaction&.valid?

      Ticketing::OrderBillingService.new(@order)
                                    .settle_balance_with_bank_transaction(bank_transaction)
      bank_transaction.save if bank_transaction.new_record?
      bank_transaction
    end

    private

    def bank_transaction
      @bank_transaction ||= if @params[:bank_transaction][:open]
                              @order.open_bank_transaction
                            elsif @params[:bank_transaction][:previous]
                              bank_transaction_from_most_recent
                            else
                              bank_transaction_from_new_params
                            end
    end

    def bank_transaction_from_most_recent
      return if (previous = @order.most_recent_bank_transaction).nil?

      build_bank_transaction(previous.attributes.slice('name', 'iban'))
    end

    def bank_transaction_from_new_params
      build_bank_transaction(@params[:bank_transaction].slice(:name, :iban))
    end

    def build_bank_transaction(transaction_params)
      @order.bank_transactions.new(transaction_params)
    end
  end
end
