class Tickets::Bunch < ActiveRecord::Base
	include Tickets::Cancellable
	
	has_many :tickets
	belongs_to :assignable, :polymorphic => true
	
	validates_length_of :tickets, :minimum => 1
	validate :validate_tickets
	
	def add_tickets_with_numbers_and_reservations(numbers, reservations)
		if numbers.present?
			numbers.each do |type_id, number|
				type = Tikets::TicketType.find(type_id) rescue nil
				number.to_i.times do
					ticket = self.tickets.build
					ticket.type = type
					ticket.reservation_id = reservations.shift
				end
			end
		end
	end
	
end
