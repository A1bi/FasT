module Ticketing
  class Seating < BaseModel
    has_many :blocks
    has_many :seats, through: :blocks

    def bound_to_seats?
      self[:number_of_seats] < 1
    end

    def number_of_seats
      bound_to_seats? ? seats.count : self[:number_of_seats]
    end
  end
end
