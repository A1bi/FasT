class Ticketing::Cancellation < BaseModel
  has_many :tickets, dependent: :nullify
end
