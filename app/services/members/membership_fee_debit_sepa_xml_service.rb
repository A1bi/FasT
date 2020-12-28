# frozen_string_literal: true

module Members
  class MembershipFeeDebitSepaXmlService
    LOCAL_INSTRUMENT = 'COR1'
    BATCH_BOOKING = true

    def initialize(submission:)
      @submission = submission
    end

    def xml
      @debit = SEPA::DirectDebit.new(debit_info)
      @debit.message_identification = "FasT/membership-fee/#{@submission.id}"

      @submission.payments.find_each do |payment|
        add_transaction_for_payment(payment)
      end

      @debit.to_xml
    end

    private

    def debit_info
      %i[name iban creditor_identifier].index_with { |key| translate(key) }
    end

    def add_transaction_for_payment(payment)
      member = payment.member
      mandate = member.sepa_mandate
      return if member.sepa_mandate.nil?

      @debit.add_transaction(
        name: mandate.debtor_name[0..69],
        iban: mandate.iban,
        amount: payment.amount,
        remittance_information:
          translate(:remittance_information, member: member.name.full),
        mandate_id: mandate.number(prefixed: true),
        mandate_date_of_signature: mandate.issued_on,
        instruction: payment.id,
        local_instrument: LOCAL_INSTRUMENT,
        sequence_type: recurring_payment?(payment) ? 'RCUR' : 'FRST',
        batch_booking: BATCH_BOOKING,
        requested_date: ::Date.tomorrow
      )
    end

    def recurring_payment?(payment)
      payment.member.membership_fee_payments.count > 1
    end

    def translate(key, options = {})
      options[:scope] = %i[members membership_fee_payments debit_submissions]
      I18n.t(key, options)
    end
  end
end
