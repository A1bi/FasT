# frozen_string_literal: true

module Ticketing
  class ReceivedTransferPaymentProcessService
    ORDER_NUMBER_PATTERN = /([^\d]|\b)(\d{6})\b/

    def initialize
      @ebics_service = EbicsService.new
    end

    def execute
      credit_transactions.each do |transaction|
        log "Processing transaction from #{transaction.name}: #{transaction.sepa['SVWZ']}..."

        BankTransaction.transaction do
          if transaction_already_processed?(transaction)
            log 'Already processed, skipping.'
            next
          end
          if (orders = orders_matching_transaction(transaction)).empty?
            log 'No matching orders found, skipping.'
            next
          end
          orders.each(&:lock!)
          if transaction_amount_matches_orders?(transaction, orders)
            log 'Amount does not match, skipping.'
            next
          end

          BankTransaction.create!(orders:, raw_source: transaction, raw_source_sha: transaction.sha)

          orders.each do |order|
            OrderPaymentService.new(order).mark_as_paid
            log "Marked order #{order.number} as paid."
          end
        end
      end
    end

    private

    def credit_transactions
      @ebics_service.transactions(fetch_from_date).select do |transaction|
        transaction.credit? && transaction.sepa['MREF'].blank?
      end
    end

    def fetch_from_date
      (BankTransaction.received.maximum("(raw_source->>'date')::date") || 1.week.ago).to_date
    end

    def transaction_already_processed?(transaction)
      BankTransaction.where(raw_source_sha: transaction.sha).any?
    end

    def orders_matching_transaction(transaction)
      transaction.sepa['SVWZ'].scan(ORDER_NUMBER_PATTERN).map do |match|
        Order.unpaid.find_by(number: match[1])
      end.compact
    end

    def transaction_amount_matches_orders?(transaction, orders)
      orders.sum(&:balance) != -transaction.amount
    end

    def log(msg)
      Rails.logger.info(msg)
    end
  end
end
