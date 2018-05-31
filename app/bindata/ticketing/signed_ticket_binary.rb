module Ticketing
  class SignedTicketBinary < BinData::Record
    Ticketing::TicketBinary # workaround for BinData bug with enabled eager loading

    ticket_binary :ticket
    string        :signature, length: 20
  end
end
