class Ticketing::Seat < ActiveRecord::Base
  attr_accessible :number, :row, :block_id, :position_x, :position_y
	
	belongs_to :block
	has_many :reservations
  has_many :tickets
  
  validates_presence_of :number, on: :create
	
	def available_on_date?(date)
    tickets.where(date_id: date).empty? && reservations.where(date_id: date).empty?
	end
end
