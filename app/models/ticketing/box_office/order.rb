module Ticketing
  module BoxOffice
    class Order < Order
      belongs_to :box_office
    end
  end
end
