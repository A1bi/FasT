module Ticketing
  module BoxOffice
    class BoxOffice < BaseModel
      include Ticketing::Billable

      has_many :purchases, dependent: :destroy, autosave: true
    end
  end
end
