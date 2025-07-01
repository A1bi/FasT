# frozen_string_literal: true

module Ticketing
  class TransferSepaXmlService < SepaXmlService
    private

    def transactions
      @transactions ||= @submission.transactions.transfers
    end

    def message_info
      Settings.ticketing.target_bank_account.to_h.slice(:name, :iban)
    end

    def transaction_amount(transaction)
      -super
    end

    def message_class
      SEPA::CreditTransfer
    end

    def transaction_type
      :transfer
    end
  end
end
