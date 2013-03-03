class Tickets::Order < ActiveRecord::Base
  attr_accessible :email, :first_name, :gender, :last_name, :phone, :plz
	
	has_one :bunch, :as => :assignable, :validate => true
	
	validate :validate_adress
	
	def update_info(info)
		return if info.try(:[], :info).nil?
		self.attributes = info[:info][:address]
		if info[:info][:date].present?
			self.build_bunch
			self.bunch.add_tickets_with_numbers_and_reservations(info[:info][:date][:numbers] || {}, info[:reservations] || [])
		end
	end
	
	def validate_address
		self.validates_presence_of :email, :first_name, :last_name, :phone, :plz, :bunch
		self.validates_inclusion_of :gender, :in => 0..1
		self.validates_numericality_of :plz, :only_integer => true, :less_than => 100000, :greater_than => 1000
	  self.validates_format_of :email, :with => /^([a-z0-9-]+\.?)+@([a-z0-9-]+\.)+[a-z]{2,9}$/i
	end
end
