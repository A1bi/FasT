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

        # reaching this line means transactions have been successfully submitted to the bank,
        # suppress any possible errors from here so the database transaction is committed and
        # therefore this job will not run again with these transactions and they will not be submitted again
        suppress_in_production(StandardError) do
          submission.update(ebics_response: response)
        end
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
