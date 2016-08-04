module Ticketing
  module TicketingHelper
    def obfuscated_iban(iban)
      iban[0..1] + "X" * (iban.length - 5) + iban[-3..-1]
    end

    def format_billing_amount(amount)
      (amount > 0 ? "+" : "") + number_to_currency(amount)
    end
  end
end
