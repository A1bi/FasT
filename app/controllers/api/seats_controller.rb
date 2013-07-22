class Api::SeatsController < ApplicationController
  def index
    response = {
      seats: Hash[Ticketing::Event.current.dates.map do |date|
        [date.id, Hash[Ticketing::Seat.with_availability_on_date(date).map { |seat| seat.node_hash }]]
      end]
    }
    
    render :json => response
  end
end
