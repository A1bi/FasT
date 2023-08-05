# frozen_string_literal: true

module Ticketing
  class EventDate < ApplicationRecord
    include Cancellable
    include Statistics

    belongs_to :event, proc { including_ticketing_disabled }, touch: true, inverse_of: :dates
    has_many :tickets, dependent: :nullify, foreign_key: :date_id, inverse_of: :date
    has_many :reservations, dependent: :destroy, foreign_key: :date_id, inverse_of: :date

    before_validation :set_covid19_check_in_url

    class << self
      def upcoming(offset: 0.days)
        where('date > ?', offset.before(Time.current))
      end

      def past
        where('date <= ?', Time.current)
      end
    end

    def sold_out?
      threshold = date.past? ? 97 : 100
      statistics[:percentage] >= threshold
    end

    def admission_time
      event.admission_duration.minutes.before(date)
    end

    def number_of_seats
      event.seating.number_of_seats
    end

    def number_of_booked_seats
      statistics[:total]
    end

    private

    def statistics
      ticket_stats_for_event(event).dig(:total, id) || { total: 0, percentage: 0 }
    end

    def set_covid19_check_in_url
      return unless event.covid19?

      self.covid19_check_in_url ||= CoronaPresenceTracing::CWACheckIn.new(
        description: event.name,
        address: event.location.address,
        start_time: admission_time,
        end_time: 2.hours.after(date),
        location_type: :temporary_cultural_event,
        default_check_in_length: 120
      ).url
    end
  end
end
