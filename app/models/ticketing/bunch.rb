module Ticketing
  class Bunch < ActiveRecord::Base
  	include Cancellable, RandomUniqueID
	
  	has_many :tickets, :after_add => :added_ticket
  	belongs_to :assignable, :polymorphic => true, :touch => true
    has_random_unique_id :number, 6
	
  	validates_length_of :tickets, :minimum => 1
	
    def added_ticket(ticket)
      self[:total] = ticket.type.price.to_f + total.to_f
    end
  end
end
