# frozen_string_literal: true

module Ticketing
  class TicketCheckInJob < ApplicationJob
    def perform(ticket_id:, date:, medium:)
      tickets_to_check_in(ticket_id).each do |t|
        t.check_ins.create!(date: date, medium: medium)
      end
    end

    private

    def tickets_to_check_in(ticket_id)
      ticket = Ticket.find(ticket_id)
      if ticket.event.covid19?
        ticket.order.tickets.valid
      else
        [ticket]
      end
    end
  end
end
