class OrdersController < ApplicationController
  before_filter :disable_slides
  before_filter :set_event_info, :only => [:new, :new_retail]
  
  def new_retail
    @store = Ticketing::Retail::Store.first
  end
  
  private
  
	def set_event_info
		@event = Ticketing::Event.current
		@seats = Ticketing::Seat.order(:number)
		@ticket_types = Ticketing::TicketType.order(:price)
  end
end
