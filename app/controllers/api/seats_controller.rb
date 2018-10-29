class Api::SeatsController < ApplicationController
  def availability
    events = Ticketing::Event.current.includes(:dates)
    dates = events.collect(&:dates).flatten

    render json: {
      events: Hash[events.map do |event|
        [event.id, { dates: event.dates.pluck(:id) }]
      end],
      seats: Hash[dates.map do |date|
        next if date.event.seating.nil?
        [date.id, Hash[date.event.seating.seats.with_availability_on_date(date).map(&:node_hash)]]
      end]
    }
  end
end
