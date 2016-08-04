module Ticketing
  class BoxOffice::Order < Order
    belongs_to :box_office
  end
end
