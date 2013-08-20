module Ticketing
  class SeatsController < BaseController
    before_filter :find_seat, :only => [:update]
  
    def index
      @seats = Ticketing::Seat.order(:number)
      
      respond_to do |format|
        
        format.html do
          @blocks = Ticketing::Block.order(:id)
          @new_seats = @blocks.map do |block|
            seat = Ticketing::Seat.new
            seat.block = block
            seat
          end
        end
        
        format.json { render json: { ok: true, html: render_to_string("application/ticketing/_seats", locals: { seats: @seats, numbers: true, no_stage: true }, formats: :html, layout: false) } }
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
      # TODO: protect seats from being changed after sale has begun
      # @seat.update_attributes(params[:seat])
    
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
  end
end