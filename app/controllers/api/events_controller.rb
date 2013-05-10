class Api::EventsController < ApplicationController
  def current
    event = Ticketing::Event.current
    dates = event.dates
    
    response = {
      name: event.name,
      dates: dates.map { |date| { id: date.id.to_s, date: date.date.to_i } },
      ticket_types: Ticketing::TicketType.all.map { |type| { id: type.id.to_s, name: type.name, info: type.info || "", price: type.price } },
      
      seats: Ticketing::Seat.includes(:tickets, :reservations).all.map do |seat|
        reserved = {};
        dates.each do |date|
          dateReserved = false
          [:tickets, :reservations].each do |type|
            seat.send(type).each do |ticket|
              if ticket.date_id == date.id
                dateReserved = true
                break
              end
            end
            break if dateReserved
          end
          
          reserved[date.id] = dateReserved
        end
        
        { :id => seat.id.to_s, :block => seat.block.name, :row => seat.row.to_s, :number => seat.number.to_s, :reserved => reserved, :grid => { :x => seat.position_x, :y => seat.position_y } }
      end
    }
    
    render :json => response
  end
end
