module Ticketing
  module TicketingHelper
    def obfuscated_iban(iban)
      iban[0..1] + "X" * (iban.length - 5) + iban[-3..-1]
    end
  end
end