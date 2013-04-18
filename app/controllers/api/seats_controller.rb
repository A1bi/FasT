class Api::SeatsController < ApplicationController
  def index
    # TODO: optimize sql query
    seats = Ticketing::Seat.all.map do |seat|
      reserved = {};
      Ticketing::Event.current.dates.each { |date| reserved[date.id] = !seat.available_on_date?(date) }
      { :id => seat.id, :reserved => reserved, :grid => { :x => seat.position_x, :y => seat.position_y } }
    end
    
    render :json => seats
  end
end
