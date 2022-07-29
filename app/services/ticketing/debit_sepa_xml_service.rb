# frozen_string_literal: true

module Ticketing
  class DebitSepaXmlService
    LOCAL_INSTRUMENT = 'COR1'
    SEQUENCE_TYPE = 'OOFF'
    BATCH_BOOKING = true

    def initialize(submission_id:)
      @submission_id = submission_id
    end

    def xml
      debit = SEPA::DirectDebit.new(debit_info)
      debit.message_identification = "FasT/#{submission.id}"

      submission.charges.each do |charge|
        debit.add_transaction(transaction_from_charge(charge))
      end

      debit.to_xml
    end

    def submission
      @submission ||= BankChargeSubmission.find(@submission_id)
    end

    private

    def debit_info
      %i[name iban creditor_identifier].index_with { |key| translate(key) }
    end

    def transaction_from_charge(charge)
      {
        name: charge.name[0..69],
        iban: charge.iban,
        amount: charge.amount,
        instruction: charge.id,
        remittance_information: translate(:debit_remittance_information,
                                          number: charge.chargeable.number),
        mandate_id: charge.mandate_id,
        mandate_date_of_signature: charge.created_at.to_date,
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
