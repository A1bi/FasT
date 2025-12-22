# frozen_string_literal: true

module Ticketing
  class ReceivedTransferPaymentProcessService
    ORDER_NUMBER_PATTERN = /([^\d]|\b)(\d{6})\b/

    def initialize
      @ebics_service = EbicsService.new
    end

    def execute
      statement_entries.each do |entry|
        log "Processing entry from '#{entry.name}': '#{entry.remittance_information&.truncate(30)}'..."

        BankTransaction.transaction do
          if entry_already_processed?(entry)
            log 'Already processed, skipping.'
            next
          end
          if (orders = orders_matching_entry(entry)).empty?
            log 'No matching orders found, skipping.'
            next
          end
          orders.each(&:lock!)
          if entry_amount_matches_orders?(entry, orders)
            log 'Amount does not match, skipping.'
            next
          end

          BankTransaction.create!(orders:, camt_entry: entry)

          orders.each do |order|
            OrderPaymentService.new(order).mark_as_paid
            log "Marked order #{order.number} as paid."
          end
        end
      end
    end

    private

    def statement_entries
      @ebics_service.statement_entries(fetch_from_date).select do |entry|
        if entry.transactions.count != 1
          Sentry.capture_message('bank statement entry does not contain exactly one transaction',
                                 extra: { entry_bank_reference: entry.bank_reference })
          next
        end

        entry.credit? && entry.transactions[0].mandate_reference.blank?
      end
    end

    def fetch_from_date
      (BankTransaction.received.maximum("(camt_source#>>'{BookgDt,Dt}')::date") || 1.week.ago).to_date
    end

    def entry_already_processed?(entry)
      BankTransaction.where("camt_source->>'AcctSvcrRef' = ?", entry.bank_reference).any?
    end

    def orders_matching_entry(entry)
      return Order.none if entry.remittance_information.blank?

      entry.remittance_information.scan(ORDER_NUMBER_PATTERN).map do |match|
        Order.unpaid.find_by(number: match[1])
      end.compact
    end

    def entry_amount_matches_orders?(entry, orders)
      orders.sum(&:balance) != -entry.amount
    end

    def log(msg)
      Rails.logger.info(msg)
    end
  end
end
