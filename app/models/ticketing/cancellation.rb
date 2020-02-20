module Ticketing
  class Cancellation < ApplicationRecord
    has_many :tickets, dependent: :nullify
  end
end
