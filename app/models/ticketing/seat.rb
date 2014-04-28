module Ticketing
  class Seat < BaseModel
    belongs_to :block, touch: true
  	has_many :reservations, dependent: :destroy
    has_many :tickets
  
    validates_presence_of :number, on: :create
  
    def taken?(date = nil)
      return !taken.zero? if !date
      !tickets.where(date_id: date).cancelled(false).empty?
    end
  
    def reserved?(date = nil)
      return !reserved.zero? if !date
      !reservations.where(date_id: date).empty?
    end
  
    def node_hash(date = nil)
      [id, { available: !taken?(date), reserved: reserved?(date) }]
    end
  
    def self.with_availability_on_date(date)
      select("ticketing_seats.*, COUNT(ticketing_tickets.id) > 0 AS taken, COUNT(ticketing_reservations.id) > 0 AS reserved")
      .joins("LEFT JOIN ticketing_tickets ON ticketing_tickets.seat_id = ticketing_seats.id AND ticketing_tickets.date_id = #{date.id} AND #{Ticket.arel_table[:cancellation_id].eq(nil).to_sql}")
      .joins("LEFT JOIN ticketing_reservations ON ticketing_reservations.seat_id = ticketing_seats.id AND ticketing_reservations.date_id = #{date.id}")
      .group("ticketing_seats.id")
    end
  end
end