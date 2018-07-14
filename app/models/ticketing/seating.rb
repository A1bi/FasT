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

    def unreserved_seats_on_date(date)
      return seats unless bound_to_seats?

      seats = Ticketing::Seat.arel_table
      reservations = Ticketing::Reservation.arel_table
      tickets = Ticketing::Ticket.arel_table
      join = self.seats.arel
                 .join(tickets, Arel::Nodes::OuterJoin)
                 .on(
                    tickets[:seat_id].eq(seats[:id])
                    .and(tickets[:date_id].eq(date.id))
                    .and(tickets[:cancellation_id].eq(nil))
                  )
                 .join(reservations, Arel::Nodes::OuterJoin)
                 .on(
                   reservations[:seat_id].eq(seats[:id])
                   .and(reservations[:date_id].eq(date.id))
                   .and(tickets[:id].eq(nil))
                 )
                 .join_sources

      Ticketing::Seat.joins(join).where(reservations[:id].eq(nil))
    end

    def number_of_unreserved_seats_on_date(date)
      bound_to_seats? ? unreserved_seats_on_date(date).count : self[:number_of_seats]
    end
  end
end
