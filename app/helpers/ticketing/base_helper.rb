module Ticketing
  module BaseHelper
  	def css_class_for_seat_availability(seat)
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