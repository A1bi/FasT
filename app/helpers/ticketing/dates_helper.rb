module Ticketing
  module DatesHelper
    def seat_options(seat)
      { class: css_class_for_seat_availability(seat) }
    end
  end
end