module Ticketing
  class ReservationsController < BaseController
    before_filter :split_seats, :only => [:update, :destroy]
    
    cache_sweeper :seat_sweeper, :only => [:update, :destroy]
    
    def update
      if params[:new_group_name].present?
        group = ReservationGroup.create(name: params[:new_group_name])
      else
        group = ReservationGroup.find(params[:group])
      end
      
      date = EventDate.find(params[:date])
      @seats.each do |seatId|
        seat = Seat.find(seatId)
        reservation = Reservation.where(seat_id: seat, date_id: date).first || Reservation.new({seat: seat, date: date}, without_protection: true)
        reservation.group = group
        reservation.save
      end
      
      redirect_to :back
    end
    
    def destroy
      Reservation.where(seat_id: @seats, date_id: params[:date]).destroy_all
      
      redirect_to :back
    end
    
    private
    
    def split_seats
      @seats = params[:seats].split(",")
    end
  end
end