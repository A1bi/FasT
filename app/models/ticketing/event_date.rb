# frozen_string_literal: true

module Ticketing
  class EventDate < ApplicationRecord
    include Cancellable
    include Statistics

    SOLD_OUT_THRESHOLD = 97

    belongs_to :event, proc { including_ticketing_disabled }, touch: true, inverse_of: :dates
    has_many :tickets, dependent: :nullify, foreign_key: :date_id, inverse_of: :date
    has_many :reservations, dependent: :destroy, foreign_key: :date_id, inverse_of: :date

    delegate :future?, :past?, to: :date
    delegate :number_of_seats, to: :event

    class << self
      def upcoming(offset: 0.days)
        where('date > ?', offset.before(Time.current))
      end

      def past
        where(date: ..Time.current)
      end

      def imminent
        upcoming(offset: 1.day).order(Arel.sql('abs(extract(epoch from (date - ?))) ASC', Time.current)).first
      end
    end

    def sold_out?
      return number_of_available_seats.zero? unless past?

      statistics[:percentage] >= SOLD_OUT_THRESHOLD
    end

    def admission_time
      event.admission_duration.minutes.before(date)
    end

    def number_of_unreserved_seats
      event.seating? ? event.seating.unreserved_seats_on_date(self).count : number_of_seats
    end

    def number_of_available_seats
      # use valid instead of sold because sold include resale tickets
      number_of_unreserved_seats - number_of_valid_tickets
    end

    def number_of_sold_tickets
      statistics[:total]
    end

    def number_of_valid_tickets
      tickets.valid.count
    end

    private

    def statistics
      ticket_stats_for_event(event).dig(:total, id) || { total: 0, percentage: 0 }
    end
  end
end
