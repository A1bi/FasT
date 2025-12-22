# frozen_string_literal: true

module SepaFileParser
  module EntryExtensions
    delegate :name, :iban, :remittance_information, to: :transaction

    def transaction
      transactions[0]
    end
  end

  Entry.prepend EntryExtensions
end
