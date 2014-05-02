class Ticketing::Cancellation < ActiveRecord::Base
  has_many :orders, dependent: :nullify
  has_many :tickets, dependent: :nullify
end
