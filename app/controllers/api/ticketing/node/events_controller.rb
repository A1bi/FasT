# frozen_string_literal: true

module Api
  module Ticketing
    module Node
      class EventsController < ApiController
        def index
          events = ::Ticketing::Event.with_future_dates
          dates = events.collect(&:dates).flatten

          render json: {
            events: events.to_h { |event| event_info(event) },
            seats: dates.filter_map { |date| date_info(date) }.to_h
          }
        end

        private

        def event_info(event)
          [event.id, { dates: event.dates.pluck(:id) }]
        end

        def date_info(date)
          return if date.event.seating.nil?

          [date.id, seats_for_date(date).to_h(&:node_hash)]
        end

        def seats_for_date(date)
          date.event.seating.seats.with_availability_on_date(date)
        end
      end
    end
  end
end
