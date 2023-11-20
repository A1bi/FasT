# frozen_string_literal: true

module Ticketing
  class EventDate < ApplicationRecord
    include Cancellable
    include Statistics

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
        where('date <= ?', Time.current)
      end
    end

    def sold_out?
      threshold = past? ? 97 : 100
      statistics[:percentage] >= threshold
    end

    def admission_time
      event.admission_duration.minutes.before(date)
    end

    def number_of_unreserved_seats
      event.seating? ? event.seating.unreserved_seats_on_date(self).count : number_of_seats
    end

    def number_of_booked_seats
      statistics[:total]
    end

    private

    def statistics
      ticket_stats_for_event(event).dig(:total, id) || { total: 0, percentage: 0 }
    end
  end
end
