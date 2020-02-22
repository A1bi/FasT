# frozen_string_literal: true

module Ticketing
  class TicketBinary < BinData::Record
    bit16     :id
    bit20     :order_number
    bit8      :order_index
    bit8      :date_id
    bit8      :type_id
    bit12     :seat_id

    def self.from_ticket(ticket)
      unless ticket.is_a?(Ticketing::Ticket)
        raise 'ticket must be an instance of Ticketing::Ticket'
      end

      new(
        id: ticket.id,
        order_number: ticket.order.number,
        order_index: ticket.order_index,
        date_id: ticket.date_id,
        type_id: ticket.type_id,
        seat_id: ticket.seat_id
      )
    end
  end
end
