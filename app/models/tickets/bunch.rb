class Tickets::Bunch < ActiveRecord::Base
	include Tickets::Cancellable
	
	has_many :tickets, :after_add => :added_ticket
	belongs_to :assignable, :polymorphic => true
	
	validates_length_of :tickets, :minimum => 1
	
  def added_ticket(ticket)
    self[:total] = ticket.type.price.to_f + total.to_f
  end
end
