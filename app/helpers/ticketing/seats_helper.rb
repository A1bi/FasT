module Ticketing
  module SeatsHelper
    def seat_options(seat)
      { :style => "background: " + seat.block.color + ";" }
    end
  end
end