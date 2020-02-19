module Ticketing
  class Block < BaseModel
    belongs_to :seating
    has_many :seats, dependent: :destroy
  end
end
