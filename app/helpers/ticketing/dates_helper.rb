module Ticketing
  module DatesHelper
    def seat_options(seat)
      { class: css_class_for_seat(seat) }
    end
    
    def css_class_for_seat(seat)
      if seat.available_on_date? @date
        "available"
      elsif seat.reserved_on_date? @date
        "reserved"
      elsif seat.booked_on_date? @date
        "taken"
      end
    end
  end
end