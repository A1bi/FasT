# frozen_string_literal: true

module Api
  module Ticketing
    module Node
      class EventsController < ApiController
        def index
          events = ::Ticketing::Event.current.includes(:dates)
          dates = events.collect(&:dates).flatten

          render json: {
            events: events.map { |event| event_info(event) }.to_h,
            seats: dates.filter_map { |date| date_info(date) }.to_h
          }
        end

        private

        def event_info(event)
          [event.id, { dates: event.dates.pluck(:id) }]
        end

        def date_info(date)
          return if date.event.seating.nil?

          [date.id, seats_for_date(date).map(&:node_hash).to_h]
        end

        def seats_for_date(date)
          date.event.seating.seats.with_availability_on_date(date)
        end
      end
    end
  end
end
