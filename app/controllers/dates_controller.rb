class DatesController < ApplicationController
  before_filter :prepare_ticket_prices
  before_filter :prepare_event
  
  def don_camillo
  end
  
  def jedermann
  end
  
  private
  
  def prepare_ticket_prices
    @ticket_types = Ticketing::TicketType.exclusive(false).order("price DESC")
  end
  
  def prepare_event
    @event = Ticketing::Event.by_identifier(params[:action]) || Ticketing::Event.first
  end
end
