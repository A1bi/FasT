class Ticketing::Block < BaseModel
  has_many :seats, :dependent => :destroy
end
