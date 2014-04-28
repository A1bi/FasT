class Ticketing::Cancellation < ActiveRecord::Base
  has_many :bunches, dependent: :nullify
  has_many :tickets, dependent: :nullify
end
