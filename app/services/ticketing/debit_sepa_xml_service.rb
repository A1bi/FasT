# frozen_string_literal: true

module Ticketing
  class DebitSepaXmlService
    LOCAL_INSTRUMENT = 'COR1'
    SEQUENCE_TYPE = 'OOFF'
    BATCH_BOOKING = false

    def initialize(submission)
      @submission = submission
    end

    def xml
      return if transactions.none?

      debit = SEPA::DirectDebit.new(debit_info)
      debit.message_identification = "FasT/#{@submission.id}/debit"

      transactions.each do |transaction|
        debit.add_transaction(transaction_info(transaction))
      end

      debit.to_xml
    end

    private

    def transactions
      @transactions ||= @submission.transactions.debits
    end

    def debit_info
      Settings.ticketing.target_bank_account.to_h.slice(:name, :iban, :creditor_identifier)
    end

    def transaction_info(transaction)
      {
        name: transaction.name[0..69],
        iban: transaction.iban,
        amount: transaction.amount,
        instruction: transaction.id,
        remittance_information: remittance_information(transaction),
        mandate_id: transaction.mandate_id,
        mandate_date_of_signature: transaction.created_at.to_date,
        local_instrument: LOCAL_INSTRUMENT,
        sequence_type: SEQUENCE_TYPE,
        batch_booking: BATCH_BOOKING,
        requested_date:
      }
    end

    def requested_date
      Date.tomorrow
    end

    def remittance_information(transaction)
      I18n.t('ticketing.payments.submissions.debit_remittance_information', number: transaction.order.number)
    end
  end
end
