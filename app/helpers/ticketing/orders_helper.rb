module Ticketing
  module OrdersHelper
    def seat_options(seat)
      { class: css_class_for_seat(seat) }
    end
    
    def css_class_for_seat(seat)
      @seats_in_order ||= Hash[@order.tickets.map { |ticket| [ticket.seat, ticket.cancelled?] }]
      in_tickets = @seats_in_order[seat]
      if !in_tickets.nil?
        classes = [:chosen]
        classes << :cancelled if in_tickets
        classes.join(" ")
      end
    end
  end
end