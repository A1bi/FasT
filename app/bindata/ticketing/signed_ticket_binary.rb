module Ticketing
  class SignedTicketBinary < BinData::Record
    ticket_binary :ticket
    string        :signature, length: 20
  end
end
