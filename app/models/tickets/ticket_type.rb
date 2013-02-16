class Tickets::TicketType < ActiveRecord::Base
  attr_accessible :name, :price, :info
	
	has_many :tickets, :foreign_key => "type_id"
end
