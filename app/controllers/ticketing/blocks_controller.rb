module Ticketing
  class BlocksController < BaseController
    before_filter :find_block, :only => [:edit, :update, :destroy]
    
    def new
      @block = Ticketing::Block.new
      @block.color = ""
    end
  
    def create
      @block = Ticketing::Block.create(block_params)
      redirect_to_seating
    end
  
    def update
      @block.update_attributes(block_params)
      redirect_to_seating
    end
    
    def destroy
      @block.destroy
      redirect_to_seating
    end
  
    private
  
    def find_block
      @block = Ticketing::Block.find(params[:id])
    end
    
    def redirect_to_seating
      redirect_to ticketing_seats_path
    end
    
    def block_params
      params.require(:ticketing_block).permit(:name, :color)
    end
  end
end