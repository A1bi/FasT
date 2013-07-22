module Ticketing
  module StatisticsHelper
    def seat_options(seat)
      { class: css_class_for_seat(seat) }
    end
    
    def css_class_for_seat(seat)
      if seat.reserved?
        "reserved"
      elsif seat.taken?
        "taken"
      else
        "available"
      end
    end
  end
end