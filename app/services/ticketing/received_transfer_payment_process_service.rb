# frozen_string_literal: true

module Ticketing
  class ReceivedTransferPaymentProcessService
    ORDER_NUMBER_PATTERN = /(^|[^\d]+)(\d{6})([^\d]+|$)/

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
          if (order = order_matching_transaction(transaction))&.lock!.nil?
            log 'No matching order found, skipping.'
            next
          end
          if transaction_amount_matches_order?(transaction, order)
            log 'Amount does not match, skipping.'
            next
          end

          BankTransaction.create!(order:, raw_source: transaction, raw_source_sha: transaction.sha)
          OrderPaymentService.new(order).mark_as_paid
          log "Marked order #{order.number} as paid."
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

    def order_matching_transaction(transaction)
      return unless transaction.sepa['SVWZ'] =~ ORDER_NUMBER_PATTERN

      Order.unpaid.find_by(number: Regexp.last_match(2))
    end

    def transaction_amount_matches_order?(transaction, order)
      order.balance != -transaction.amount
    end

    def log(msg)
      Rails.logger.info(msg)
    end
  end
end
