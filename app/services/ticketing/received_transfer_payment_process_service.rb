# frozen_string_literal: true

module Ticketing
  class ReceivedTransferPaymentProcessService
    ORDER_NUMBER_PATTERN = /(^|[^\d]+)(\d{6})([^\d]+|$)/

    def initialize
      @ebics_service = EbicsService.new
    end

    def execute
      credit_transactions.each do |transaction|
        next unless transaction.sepa['SVWZ'] =~ ORDER_NUMBER_PATTERN
        next if (order = Order.unpaid.find_by(number: Regexp.last_match(2))).nil?
        next if order.balance != -transaction.amount

        BankTransaction.create(order:, raw_source: transaction)
        OrderPaymentService.new(order).mark_as_paid
      end
    end

    private

    def credit_transactions
      @ebics_service.transactions(fetch_from_date).select(&:credit?)
    end

    def fetch_from_date
      (BankTransaction.received.maximum(:created_at) || 1.week.ago).to_date
    end
  end
end
