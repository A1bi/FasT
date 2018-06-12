class Api::SeatsController < ApplicationController
  def index
    seating = Ticketing::Event.current.seating
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
    render json: {
      seats: Hash[Ticketing::Event.current.dates.map do |date|
        [date.id, Hash[Ticketing::Seat.with_availability_on_date(date).map { |seat| seat.node_hash }]]
      end]
    }
  end
end
