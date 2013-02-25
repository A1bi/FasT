class Tickets::Bunch < ActiveRecord::Base
	include Tickets::Cancellable
	
	has_many :tickets
	belongs_to :assignable, :polymorphic => true
end
