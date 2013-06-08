module Ticketing
  class DatesController < BaseController
    before_filter :find_date, :only => [:show]
    
    def index
      @dates = Ticketing::EventDate.order(:date)
    end
    
    def show
      @seats = Ticketing::Seat.order(:id)
      @reservation_groups = Ticketing::ReservationGroup.order(:id)
    end
  
    private
  
    def find_date
      @date = Ticketing::EventDate.find(params[:id])
    end
  end
end