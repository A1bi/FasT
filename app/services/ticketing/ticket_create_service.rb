module Ticketing
  class TicketCreateService < BaseService
    include OrderingType

    attr_accessor :order, :date

    def initialize(order, date, current_user, params)
      super current_user, params

      @order = order
      @date = date
    end

    def execute
      order.errors.add(:base, 'Unknown socket id') if seats.nil?

      params[:order][:tickets].each do |type_id, number|
        ticket_type = date.event.ticket_types.find_by(id: type_id)

        if ticket_type.exclusive && !admin?
          if ticket_type.credit_left_for_member(current_user) < number
            next order.errors.add(:tickets,
                                  'Not enough credit for exclusive ticket type')
          end

          build_exclusive_ticket_type_credit_spending(ticket_type, number)
        end

        build_tickets_for_type(ticket_type, number)
      end
    end

    private

    def build_tickets_for_type(ticket_type, number)
      number.times do
        ticket = order.tickets.new(
          type: ticket_type,
          date: date
        )
        if date.event.seating.bound_to_seats?
          ticket.seat = Ticketing::Seat.find(seats.shift)
        end
      end
    end

    def build_exclusive_ticket_type_credit_spending(ticket_type, number)
      order.exclusive_ticket_type_credit_spendings.build(
        member: current_user,
        ticket_type: ticket_type,
        value: number
      )
    end

    def seats
      @seats ||= NodeApi.get_chosen_seats(params[:socket_id])
    end
  end
end
