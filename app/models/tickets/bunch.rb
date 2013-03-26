class Tickets::Bunch < ActiveRecord::Base
	include Tickets::Cancellable
	
	has_many :tickets
	belongs_to :assignable, :polymorphic => true
	
	validates_length_of :tickets, :minimum => 1
	
	def add_tickets_with_numbers_and_reservations(numbers, r)
		reservations = r.dup
		if numbers.present?
			numbers.each do |type_id, number|
				type = Tickets::TicketType.find_by_id(type_id)
				number.to_i.times do
					ticket = self.tickets.build
					ticket.type = type
					ticket.reservation_id = reservations.shift
				end
			end
		end
	end
	
end
