# frozen_string_literal: true

module Ticketing
  class TicketCheckInJob < ApplicationJob
    def perform(ticket_id:, date:, medium:)
      @check_in = Ticket.find(ticket_id).check_ins.create!(date:, medium:)
      update_subscribers
    end

    private

    def update_subscribers
      CheckInsChannel.broadcast_to(:all, checked_in:, sold:)
    end

    def checked_in
      CheckIn.where(ticket: date.tickets.valid).select(:ticket_id).distinct.count
    end

    def sold
      date.number_of_booked_seats
    end

    def date
      @date ||= @check_in.ticket.date
    end
  end
end
