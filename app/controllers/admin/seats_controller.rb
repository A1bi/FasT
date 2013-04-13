module Admin
	class SeatsController < BaseController
		before_filter :find_seat, :only => [:update]
	
		def index
			@seats = Ticketing::Seat.order(:number)
			@blocks = Ticketing::Block.order(:id)
			@new_seat = Ticketing::Seat.new
		end
	
		def create
			@seats = []
			maxNumber = Ticketing::Seat.where(row: params[:ticketing_seat][:row], block_id: params[:ticketing_seat][:block_id]).maximum(:number) || 0
		
			params[:ticketing_seat][:number].to_i.times do |i|
				seat = Ticketing::Seat.new({
					row: params[:ticketing_seat][:row],
					number: maxNumber+i+1,
				});
				seat.block_id = params[:ticketing_seat][:block_id]
				if seat.save!
					@seats << seat
				end
			end
		
			render "create.js"
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