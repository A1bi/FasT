class Tickets::Order < ActiveRecord::Base
  attr_accessible :email, :first_name, :gender, :last_name, :phone, :plz
	
	has_one :bunch, :as => :assignable, :validate => true
	
	def update_info(info)
		return if info.try(:[], :info).nil?
		self.attributes = info[:info][:address]
		if info[:info][:date].present?
			self.build_bunch
			self.bunch.add_tickets_with_numbers_and_reservations(info[:info][:date][:numbers] || {}, info[:reservations] || [])
		end
	end
	
	def validate_address
		validates_presence_of :email, :first_name, :last_name, :phone, :plz, :bunch
		validates_inclusion_of :gender, :in => 0..1
		validates_numericality_of :plz, :only_integer => true, :less_than => 100000, :greater_than => 1000
		# TODO: Add email format validation
	end
end
