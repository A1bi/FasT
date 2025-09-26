# frozen_string_literal: true

module Ticketing
  class SepaXmlService
    BATCH_BOOKING = false

    def initialize(submission)
      @submission = submission
    end

    def xml
      return if transactions.none?

      message = message_class.new(message_info)
      message.message_identification = "FasT/#{@submission.id}/#{transaction_type}"

      transactions.each do |transaction|
        message.add_transaction(transaction_info(transaction))
      end

      message.to_xml
    end

    private

    def transaction_info(transaction)
      {
        name: transaction.name[0..69],
        iban: transaction.iban,
        amount: transaction_amount(transaction),
        instruction: transaction.id,
        remittance_information: remittance_information(transaction),
        batch_booking: BATCH_BOOKING,
        requested_date: Date.tomorrow
      }
    end

    def transaction_amount(transaction)
      transaction.amount
    end

    def remittance_information(transaction)
      I18n.t("ticketing.payments.submissions.#{transaction_type}_remittance_information",
             number: transaction.orders.pluck(:number).join(', '))
    end
  end
end
