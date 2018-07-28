module Ticketing
  class CheckIn < BaseModel
    belongs_to :ticket, touch: true
    belongs_to :checkpoint, optional: true
    enum medium: %i[unknown web retail passbook box_office]
  end
end
