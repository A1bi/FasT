# frozen_string_literal: true

module Ticketing
  class TicketCreateService < BaseService
    include OrderingType

    attr_accessor :order, :date

    def initialize(order, date, current_user, params)
      super(current_user, params)

      @order = order
      @date = date
    end

    def execute
      return if date.nil? || ticket_params.blank?

      build_tickets
    end

    private

    def build_tickets
      unless enough_seats_available? || admin?
        order.errors.add(:tickets, 'Not enough seats available')
        return
      end

      ticket_params.each do |type_id, number|
        next unless number.positive?

        ticket_type = date.event.ticket_types.find_by(id: type_id)

        if ticket_type.blank?
          order.errors.add(:tickets, 'Ticket type not found')
          next
        end

        next unless validate_ticket_type(ticket_type, number)

        build_tickets_for_type(ticket_type, number)
      end
    end

    def validate_ticket_type(ticket_type, number)
      if ticket_type.box_office? && !box_office?
        order.errors.add(:tickets,
                         'Ticket type unavailable for this type of order')
        return

      elsif ticket_type_credit_required?(ticket_type)
        unless ticket_type_credit_sufficient?(ticket_type, number)
          order.errors.add(
            :tickets,
            'Remaining credit for exclusive ticket type not sufficient'
          )
          return
        end

        build_exclusive_ticket_type_credit_spending(ticket_type, number)
      end

      true
    end

    def build_tickets_for_type(ticket_type, number)
      number.times do
        ticket = order.tickets.new(
          type: ticket_type,
          date:
        )
        ticket.seat = chosen_seats.next if seating?
      end
    end

    def ticket_type_credit_required?(ticket_type)
      ticket_type.exclusive? && !admin? && !box_office?
    end

    def ticket_type_credit_sufficient?(ticket_type, number)
      ticket_type.credit_left_for_member(current_user) >= number
    end

    def build_exclusive_ticket_type_credit_spending(ticket_type, number)
      order.exclusive_ticket_type_credit_spendings.build(
        member: current_user,
        ticket_type:,
        value: number
      )
    end

    def enough_seats_available?
      date.number_of_available_seats >= ticket_params.values.sum
    end

    def chosen_seats
      @chosen_seats ||= ChosenSeatsService.new(params[:socket_id])
    end

    def seating?
      date.event.seating?
    end

    def box_office?
      order.is_a? BoxOffice::Order
    end

    def ticket_params
      params[:order][:tickets]
    end
  end
end
