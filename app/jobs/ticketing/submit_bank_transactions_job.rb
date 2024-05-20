# frozen_string_literal: true

module Ticketing
  class SubmitBankTransactionsJob < ApplicationJob
    def perform
      return unless Settings.ebics.enabled

      create_submission(submittable_transactions.debits) do |submission|
        xml = DebitSepaXmlService.new(submission).xml
        ebics_service.submit_debits(xml)
      end

      create_submission(submittable_transactions.transfers) do |submission|
        xml = TransferSepaXmlService.new(submission).xml
        ebics_service.submit_transfers(xml)
      end
    end

    private

    def create_submission(transactions)
      transactions.transaction do
        transactions.lock!
        next if transactions.none?

        submission = BankSubmission.create!(transactions:)
        response = yield(submission)
        submission.update(ebics_response: response)
      end
    end

    def submittable_transactions
      BankTransaction.submittable
    end

    def ebics_service
      @ebics_service ||= EbicsService.new
    end
  end
end
