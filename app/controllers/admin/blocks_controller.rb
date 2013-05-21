module Admin
  class BlocksController < BaseController
    before_filter :find_block, :only => [:edit, :update, :destroy]
    
    def new
      @block = Ticketing::Block.new
      @block.color = ""
    end
  
    def create
      @block = Ticketing::Block.create(params[:ticketing_block])
      redirect_to_seating
    end
  
    def update
      @block.update_attributes(params[:ticketing_block])
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
      redirect_to admin_seats_path
    end
  end
end