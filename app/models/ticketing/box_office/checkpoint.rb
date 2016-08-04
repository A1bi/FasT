module Ticketing::BoxOffice
  class Checkpoint < BaseModel
    has_many :checkins
  end
end
