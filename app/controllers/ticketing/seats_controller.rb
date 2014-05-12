module Ticketing
  class SeatsController < BaseController
    before_filter :find_all_seats, only: [:index, :edit]
  
    def index
      respond_to do |format|
        format.html
      end
    end
    
    def edit
      @blocks = Ticketing::Block.order(:id)
      @new_seats = @blocks.map do |block|
        seat = Ticketing::Seat.new
        seat.block = block
        seat
      end
    end
  
    def create
      seat = Ticketing::Seat.new(seat_params)
      if seat.save
        render json: {
          ok: true,
          id: seat.id
        }
      else
        render json: {
          ok: false
        }
      end
    end
    
    def update
      seat_params = params.permit(seats: [:number, :position_x, :position_y]).fetch(:seats, {})
      Ticketing::Seat.update(seat_params.keys, seat_params.values)
    
      render nothing: true
    end
    
    def destroy
      Ticketing::Seat.destroy(params[:ids])
      
      render nothing: true
    end
  
    private
    
    def find_all_seats
      @seats = Ticketing::Seat.order(:number)
    end
    
    def seat_params
      params.require(:seat).permit(:number, :row, :block_id, :position_x, :position_y)
    end
  end
end