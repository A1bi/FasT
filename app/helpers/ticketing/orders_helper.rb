module Ticketing
  module OrdersHelper
    def seat_options(seat)
      { class: css_class_for_seat(seat) }
    end
    
    def css_class_for_seat(seat)
      if (@seats ||= @bunch.tickets.map { |ticket| ticket.seat }).include? seat
        "chosen"
      end
    end
  end
end