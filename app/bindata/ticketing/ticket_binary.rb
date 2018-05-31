module Ticketing
  class TicketBinary < BinData::Record
    bit4      :version, asserted_value: 1
    bit8      :key_id
    bit16     :id
    bit20     :order_number
    bit8      :order_index
    bit8      :date_id
    bit8      :type_id
    bit12     :seat_id
    bit4      :medium

    def self.from_ticket(ticket, signing_key: nil, medium: nil)
      unless ticket.is_a?(Ticketing::Ticket)
        raise 'ticket must be an instance of Ticketing::Ticket'
      end

      unless signing_key.nil? || signing_key.is_a?(Ticketing::SigningKey)
        raise 'signing_key must be an instance of Ticketing::SigningKey'
      end

      new(
        key_id: signing_key&.id || 0,
        id: ticket.id,
        order_number: ticket.order.number,
        order_index: ticket.order_index,
        date_id: ticket.date_id,
        type_id: ticket.type_id,
        seat_id: ticket.seat_id,
        medium: medium || 0
      )
    end
  end
end
