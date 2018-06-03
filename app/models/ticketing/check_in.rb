module Ticketing
  class CheckIn < BaseModel
    belongs_to :ticket
    belongs_to :checkpoint
  end
end
