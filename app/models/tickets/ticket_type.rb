class Tickets::TicketType < ActiveRecord::Base
  attr_accessible :name, :price
	
	has_many :tickets, :foreign_key => "type_id"
end
