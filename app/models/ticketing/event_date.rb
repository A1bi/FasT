# frozen_string_literal: true

module Ticketing
  class EventDate < ApplicationRecord
    include Cancellable
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

    def admission_time
      event.admission_duration.minutes.before(date)
    end

    def number_of_seats
      event.seating.number_of_seats
    end

    def number_of_booked_seats
      statistics[:total]
    end

    def covid19_check_in_url
      return unless event.covid19_presence_tracing?

      super || begin
        update(covid19_check_in_url: cwa_check_in_url)
        cwa_check_in_url
      end
    end

    private

    def statistics
      ticket_stats_for_event(event).dig(:total, id) ||
        { total: 0, percentage: 0 }
    end

    def cwa_check_in_url
      @cwa_check_in_url ||= CoronaPresenceTracing::CWACheckIn.new(
        description: event.name,
        address: event.location.squish,
        start_time: admission_time.to_datetime,
        end_time: (date + 2.hours).to_datetime,
        location_type: :temporary_cultural_event,
        default_check_in_length: 120
      ).url
    end
  end
end
