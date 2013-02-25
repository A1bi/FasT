class Tickets::Order < ActiveRecord::Base
  attr_accessible :email, :first_name, :gender, :last_name, :phone, :plz
	
	has_one :bunch, :as => :assignable
end
