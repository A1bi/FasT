class Tickets::Bunch < ActiveRecord::Base
	include Cancellable
	
	has_many :tickets
end
