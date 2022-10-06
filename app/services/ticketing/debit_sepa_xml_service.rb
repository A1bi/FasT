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
      %i[name iban creditor_identifier].index_with { |key| translate(key) }
    end

    def transaction_info(transaction)
      {
        name: transaction.name[0..69],
        iban: transaction.iban,
        amount: transaction.amount,
        instruction: transaction.id,
        remittance_information: translate(:debit_remittance_information, number: transaction.order.number),
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

    def translate(key, options = {})
      options[:scope] = %i[ticketing payments submissions]
      I18n.t(key, **options)
    end
  end
end
