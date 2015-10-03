class Ticketing::Block < BaseModel
  belongs_to :seating
  has_many :seats, dependent: :destroy
end
