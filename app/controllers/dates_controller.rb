class DatesController < ApplicationController
  before_filter :prepare_ticket_prices
  
  def don_camillo
    @event = Ticketing::Event.current
  end
  
  def jedermann
    @event = Ticketing::Event.first
  end
  
  private
  
  def prepare_ticket_prices
    @ticket_types = Ticketing::TicketType.exclusive(false).order("price DESC")
  end
end
