class Api::SeatsController < ApplicationController
  def index
    # TODO: optimize sql query
    seats = Tickets::Seat.all.map do |seat|
      reserved = {};
      Tickets::Event.current.dates.each { |date| reserved[date.id] = !seat.available_on_date?(date) }
      { :id => seat.id, :reserved => reserved }
    end
    
    render :json => seats
  end
end
