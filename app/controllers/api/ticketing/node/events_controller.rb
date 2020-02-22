# frozen_string_literal: true

module Api
  module Ticketing
    module Node
      class EventsController < ApiController
        def index
          events = ::Ticketing::Event.current.includes(:dates)
          dates = events.collect(&:dates).flatten

          render json: {
            events: Hash[events.map do |event|
              event_info(event)
            end],
            seats: Hash[dates.map do |date|
              next if date.event.seating.nil?

              date_info(date)
            end]
          }
        end

        private

        def event_info(event)
          [event.id, { dates: event.dates.pluck(:id) }]
        end

        def date_info(date)
          [date.id, Hash[seats_for_date(date).map(&:node_hash)]]
        end

        def seats_for_date(date)
          date.event.seating.seats.with_availability_on_date(date)
        end
      end
    end
  end
end
