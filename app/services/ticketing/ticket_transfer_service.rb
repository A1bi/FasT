# frozen_string_literal: true

module Ticketing
  class TicketTransferService < TicketBaseService
    attr_accessor :updated_tickets

    def initialize(tickets, new_date_id:, order_id:, socket_id:, current_user:)
      super(tickets, current_user: current_user)
      @new_date_id = new_date_id
      @order_id = order_id
      @socket_id = socket_id
    end

    def execute
      ActiveRecord::Base.transaction do
        @updated_tickets = valid_tickets.filter_map { |ticket| update_ticket(ticket) }

        return if updated_tickets.none?
        return unless order.save

        create_log_event
        update_seats_with_node
      end

      true
    end

    private

    def new_date
      @new_date ||= EventDate.find(@new_date_id)
    end

    def order
      @order ||= Order.find(@order_id)
    end

    def chosen_seats
      return if @socket_id.blank? || !seating_plan?

      @chosen_seats ||= NodeApi.get_chosen_seats(@socket_id)
    end

    def update_ticket(ticket)
      ticket.date = new_date
      ticket.seat = Seat.find(chosen_seats.shift) if seating_plan?
      ticket if ticket.save && ticket.saved_changes?
    end

    def updated_seats
      updated_tickets.each_with_object({}) do |ticket, updated_seats|
        old_date_id = ticket.attribute_before_last_save(:date_id)
        old_seat = Seat.find(ticket.attribute_before_last_save(:seat_id))

        # old date and seat
        (updated_seats[old_date_id] ||= {}).merge!(
          [old_seat.node_hash(old_date_id, true)].to_h
        )

        # new date and seat
        (updated_seats[ticket.date.id] ||= {}).merge!(
          [ticket.seat.node_hash(ticket.date.id, false)].to_h
        )
      end
    end

    def create_log_event
      log_service(order).transfer_tickets(updated_tickets)
    end

    def update_seats_with_node
      NodeApi.update_seats(updated_seats) if seating_plan?
    end

    def seating_plan?
      new_date.event.seating.plan?
    end
  end
end
