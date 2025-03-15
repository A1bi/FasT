# frozen_string_literal: true

module Ticketing
  class TicketCreateService < BaseService
    include OrderingType
    include Errors

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
      return add_error(:not_enough_seats_available) unless enough_seats_available? || admin?

      ticket_params.each do |type_id, number|
        next unless number.positive?

        ticket_type = date.event.ticket_types.find_by(id: type_id)

        if ticket_type.blank?
          add_error(:unknown_ticket_type)
          next
        end

        next unless validate_ticket_type(ticket_type, number)

        build_tickets_for_type(ticket_type, number)
      end
    end

    def validate_ticket_type(ticket_type, number)
      if ticket_type.box_office? && !box_office?
        return add_error(:ticket_type_unavailable_for_order_type)

      elsif ticket_type_credit_required?(ticket_type)
        unless ticket_type_credit_sufficient?(ticket_type, number)
          add_error(:remaining_credit_for_exclusive_ticket_type_insufficient)
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
