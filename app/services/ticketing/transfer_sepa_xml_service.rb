# frozen_string_literal: true

module Ticketing
  class TransferSepaXmlService
    BATCH_BOOKING = true

    def initialize(submission)
      @submission = submission
    end

    def xml
      return if transactions.none?

      transfer = SEPA::CreditTransfer.new(transfer_info)
      transfer.message_identification = "FasT/#{@submission.id}"

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
      %i[name iban bic].index_with { |key| translate(key) }
    end

    def transaction_info(transaction)
      {
        name: transaction.name[0..69],
        iban: transaction.iban,
        amount: -transaction.amount,
        instruction: transaction.id,
        remittance_information: translate(:transfer_remittance_information, number: transaction.order.number),
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
