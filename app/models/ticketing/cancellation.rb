module Ticketing
  class Cancellation < BaseModel
    has_many :tickets, dependent: :nullify
  end
end
