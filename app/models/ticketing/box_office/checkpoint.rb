module Ticketing
  module BoxOffice
    class Checkpoint < BaseModel
      has_many :checkins, dependent: :nullify
    end
  end
end
