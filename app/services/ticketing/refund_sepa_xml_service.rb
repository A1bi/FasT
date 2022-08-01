# frozen_string_literal: true

module Ticketing
  class RefundSepaXmlService
    BATCH_BOOKING = true

    def initialize(submission_id:)
      @submission_id = submission_id
    end

    def xml
      transfer = SEPA::CreditTransfer.new(transfer_info)
      transfer.message_identification = "FasT/#{submission.id}"

      submission.refunds.each do |refund|
        transfer.add_transaction(transaction_from_refund(refund))
      end

      transfer.to_xml
    end

    def submission
      @submission ||= BankRefundSubmission.find(@submission_id)
    end

    private

    def transfer_info
      %i[name iban bic].index_with { |key| translate(key) }
    end

    def transaction_from_refund(refund)
      {
        name: refund.name[0..69],
        iban: refund.iban,
        amount: refund.amount,
        instruction: refund.id,
        remittance_information: translate(:transfer_remittance_information, number: refund.order.number),
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
