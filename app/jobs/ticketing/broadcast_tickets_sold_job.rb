# frozen_string_literal: true

module Ticketing
  class BroadcastTicketsSoldJob < ApplicationJob
    def perform(tickets: nil)
      # can't use tickets.where here because tickets might be an array instead of collection
      return if date.nil? || (tickets.present? && tickets.none? { |t| t.date == date })

      ActionCable.server.broadcast(:ticketing_tickets_sold, ticketing_tickets_sold_payload)
      ActionCable.server.broadcast(:ticketing_seats_booked, { booked_seat_ids: })
    end

    private

    def ticketing_tickets_sold_payload
      {
        tickets_sold: date.number_of_booked_seats,
        valid_tickets: date.tickets.valid.count,
        number_of_seats: date.number_of_seats
      }
    end

    def booked_seat_ids
      return [] unless date.event.seating?

      date.tickets.valid.pluck(:seat_id)
    end

    def date
      @date ||= EventDate.imminent
    end
  end
end
