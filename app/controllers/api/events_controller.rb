class Api::EventsController < ApplicationController
  def current
    event = Ticketing::Event.current
    
    response = {
      name: event.name,
      dates: event.dates.map { |date| { id: date.id.to_s, date: date.date.to_i } },
      ticket_types: Ticketing::TicketType.all.map { |type| { id: type.id.to_s, name: type.name, info: type.info || "", price: type.price || 0, exclusive: type.exclusive } },
      
      seats: Ticketing::Seat.all.map do |seat|
        { :id => seat.id.to_s, :block_name => seat.block.name, :row => seat.row.to_s, :number => seat.number.to_s, :grid => { :x => seat.position_x, :y => seat.position_y } }
      end
    }
    
    render :json => response
  end
end
