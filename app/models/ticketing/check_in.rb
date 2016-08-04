module Ticketing
  class CheckIn < BaseModel
    belongs_to :ticket
    belongs_to :checkpoint

    validates_presence_of :ticket
  end
end
