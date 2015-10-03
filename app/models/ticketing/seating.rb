module Ticketing
  class Seating < BaseModel
    has_many :blocks

    def bound_to_seats?
      number_of_seats < 1
    end
  end
end
