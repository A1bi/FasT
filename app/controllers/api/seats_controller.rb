class Api::SeatsController < ApplicationController
  def index
    seating = Ticketing::Event.find(params[:event_id]).seating
    render_cached_json [:api, :seats, :index, seating, seating.seats] do
      {
        underlay_path: "/uploads/#{seating.underlay_filename}",
        blocks: Ticketing::Block.all.map do |block|
          {
            color: block.color,
            name: block.name,
            seats: block.seats.map do |seat|
              {
                id: seat.id,
                number: seat.number,
                position: [seat.position_x, seat.position_y]
              }
            end
          }
        end
      }
    end
  end

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
