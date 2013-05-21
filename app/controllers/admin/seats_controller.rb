module Admin
	class SeatsController < BaseController
		before_filter :find_seat, :only => [:update]
	
		def index
			@seats = Ticketing::Seat.order(:number)
			@blocks = Ticketing::Block.order(:id)
			@new_seat = Ticketing::Seat.new
		end
	
		def create
			
		end
	
		def update
			@seat.update_attributes(params[:seat])
		
			render nothing: true
		end
	
		private
	
		def find_seat
			@seat = Ticketing::Seat.find(params[:id])
		end
	end
end