module Ticketing
  class ReservationGroup < BaseModel
    has_many :reservations, foreign_key: :group_id, dependent: :destroy,
                            inverse_of: :group

    validates :name, presence: true
  end
end
