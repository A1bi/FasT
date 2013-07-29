module Ticketing
  module BaseHelper
  	def css_class_for_seat_availability(seat)
      if seat.taken?
        "taken"
      elsif seat.reserved?
        "reserved"
      else
        "available"
      end
    end
  end
end