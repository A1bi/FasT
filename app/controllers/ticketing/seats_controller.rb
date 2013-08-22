module Ticketing
  class SeatsController < BaseController
    before_filter :find_seat, :only => [:update]
    before_filter :find_all_seats, :only => [:index, :edit]
  
    def index
      respond_to do |format|
        format.html { }
        format.json { render json: { ok: true, html: render_to_string("application/ticketing/_seats", locals: { seats: @seats, numbers: true, no_stage: true }, formats: :html, layout: false) } }
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
      seat = Ticketing::Seat.new(params[:seat])
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
      @seat.update_attributes(params[:seat])
    
      render nothing: true
    end
    
    def update_multiple
      params[:seat] = [params[:seat]] * params[:ids].count
      Ticketing::Seat.update(params[:ids], params[:seat])
    
      render nothing: true
    end
    
    def destroy_multiple
      Ticketing::Seat.destroy(params[:ids])
      
      render nothing: true
    end
  
    private
  
    def find_seat
      @seat = Ticketing::Seat.find(params[:id])
    end
    
    def find_all_seats
      @seats = Ticketing::Seat.order(:number)
    end
  end
end