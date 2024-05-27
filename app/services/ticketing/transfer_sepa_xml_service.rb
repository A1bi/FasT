# frozen_string_literal: true

module Ticketing
  class TransferSepaXmlService
    BATCH_BOOKING = false

    def initialize(submission)
      @submission = submission
    end

    def xml
      return if transactions.none?

      transfer = SEPA::CreditTransfer.new(transfer_info)
      transfer.message_identification = "FasT/#{@submission.id}/transfer"

      transactions.each do |transaction|
        transfer.add_transaction(transaction_info(transaction))
      end

      transfer.to_xml
    end

    private

    def transactions
      @transactions ||= @submission.transactions.transfers
    end

    def transfer_info
      Settings.ticketing.target_bank_account.to_h.slice(:name, :iban)
    end

    def transaction_info(transaction)
      {
        name: transaction.name[0..69],
        iban: transaction.iban,
        amount: -transaction.amount,
        instruction: transaction.id,
        remittance_information: remittance_information(transaction),
        batch_booking: BATCH_BOOKING
      }
    end

    def remittance_information(transaction)
      I18n.t('ticketing.payments.submissions.transfer_remittance_information', number: transaction.order.number)
    end
  end
end
