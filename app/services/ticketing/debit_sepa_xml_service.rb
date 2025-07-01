# frozen_string_literal: true

module Ticketing
  class DebitSepaXmlService < SepaXmlService
    LOCAL_INSTRUMENT = 'COR1'
    SEQUENCE_TYPE = 'OOFF'

    private

    def transactions
      @transactions ||= @submission.transactions.debits
    end

    def message_info
      Settings.ticketing.target_bank_account.to_h.slice(:name, :iban, :creditor_identifier)
    end

    def transaction_info(transaction)
      {
        **super,
        mandate_id: transaction.mandate_id,
        mandate_date_of_signature: transaction.created_at.to_date,
        local_instrument: LOCAL_INSTRUMENT,
        sequence_type: SEQUENCE_TYPE
      }
    end

    def message_class
      SEPA::DirectDebit
    end

    def transaction_type
      :debit
    end
  end
end
