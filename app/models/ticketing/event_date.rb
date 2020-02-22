# frozen_string_literal: true

module Ticketing
  class EventDate < ApplicationRecord
    include Statistics

    belongs_to :event, touch: true
    has_many :tickets, dependent: :nullify, foreign_key: :date_id,
                       inverse_of: :date
    has_many :reservations, dependent: :destroy, foreign_key: :date_id,
                            inverse_of: :date

    def self.upcoming
      where('date > ?', Time.current)
    end

    def sold_out?
      threshold = date.past? ? 97 : 100
      statistics[:percentage] >= threshold
    end

    def door_time
      date - 1.hour
    end

    def number_of_seats
      event.seating.number_of_seats
    end

    def number_of_booked_seats
      statistics[:total]
    end

    private

    def statistics
      ticket_stats_for_dates(event.dates).dig(:total, id) ||
        { total: 0, percentage: 0 }
    end
  end
end
