module Ticketing
  class Seat < BaseModel
    belongs_to :block, touch: true
    has_many :reservations, dependent: :destroy
    has_many :tickets, dependent: :nullify

    validates_presence_of :number, on: :create

    def full_number
      "#{block.name}#{number}"
    end

    def taken?(date = nil)
      return taken unless date

      tickets.where(date_id: date, invalidated: false).any?
    end

    def reserved?(date = nil)
      return reserved unless date

      reservations.where(date_id: date).any?
    end

    def node_hash(date = nil, avail = nil, res = nil)
      [id, { available: avail.nil? ? !taken?(date) : avail, reserved: res.nil? ? reserved?(date) : res }]
    end

    def self.with_availability_on_date(date)
      with_availability_on_date_and_join(date, Ticket.arel_table[:invalidated].eq(false))
    end

    def self.with_booked_status_on_date(date)
      with_availability_on_date_and_join(date, Ticket.arel_table[:cancellation_id].eq(nil))
    end

    private

    def self.with_availability_on_date_and_join(date, join)
      select('ticketing_seats.*, COUNT(ticketing_tickets.id) > 0 AS taken,' \
             'COUNT(ticketing_reservations.id) > 0 AS reserved')
        .joins('LEFT JOIN ticketing_tickets' \
               'ON ticketing_tickets.seat_id = ticketing_seats.id' \
               "AND ticketing_tickets.date_id = #{date.id} AND #{join.to_sql}")
        .joins('LEFT JOIN ticketing_reservations' \
               'ON ticketing_reservations.seat_id = ticketing_seats.id' \
               "AND ticketing_reservations.date_id = #{date.id}")
        .group('ticketing_seats.id')
    end
  end
end
