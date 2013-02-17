class Admin::SeatsController < Admin::AdminController
	before_filter :find_seat, :only => [:update]
	
	def index
		@seats = Tickets::Seat.order(:number)
		@blocks = Tickets::Block.order(:id)
		@new_seat = Tickets::Seat.new
	end
	
	def create
		@seats = []
		maxNumber = Tickets::Seat.where(row: params[:tickets_seat][:row], block_id: params[:tickets_seat][:block_id]).maximum(:number) || 0
		
		params[:tickets_seat][:number].to_i.times do |i|
			seat = Tickets::Seat.new({
				row: params[:tickets_seat][:row],
				number: maxNumber+i+1,
			});
			seat.block_id = params[:tickets_seat][:block_id]
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
		@seat = Tickets::Seat.find(params[:id])
	end
end
