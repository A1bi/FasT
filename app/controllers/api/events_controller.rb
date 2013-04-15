class Api::EventsController < ApplicationController
  def current
    event = Ticketing::Event.current
    response = {
      name: event.name,
      dates: event.dates.map { |date| date.date.to_i },
      ticket_types: Ticketing::TicketType.all.map { |type| { id: type.id, name: type.name, info: type.info, price: type.price } }
    }
    
    render :json => response
  end
end
