class Ticketing::Cancellation < ActiveRecord::Base
  attr_accessible :reason
  
  has_many :bunches, dependent: :nullify
  has_many :tickets, dependent: :nullify
end
