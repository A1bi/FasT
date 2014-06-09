class Ticketing::Cancellation < BaseModel
  has_many :orders, dependent: :nullify
  has_many :tickets, dependent: :nullify
end
