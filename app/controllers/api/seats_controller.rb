class Api::SeatsController < ApplicationController
  def index
    render json: {
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
  
  def availability
    render json: {
      seats: Hash[Ticketing::Event.current.dates.map do |date|
        [date.id, Hash[Ticketing::Seat.with_availability_on_date(date).map { |seat| seat.node_hash }]]
      end]
    }
  end
end
