# frozen_string_literal: true

module Ticketing
  class TicketTransferService < TicketBaseService
    attr_accessor :updated_tickets

    def initialize(tickets, new_date_id:, order_id:, socket_id:, current_user:, by_customer: false)
      super(tickets, current_user:)
      @new_date_id = new_date_id
      @order_id = order_id
      @socket_id = socket_id
      @by_customer = by_customer
    end

    def execute
      return if new_date.cancelled? || (@by_customer && !enough_seats_available?)

      ActiveRecord::Base.transaction do
        @updated_tickets = valid_tickets.filter_map { |ticket| update_ticket(ticket) }

        next if updated_tickets.none?
        next unless order.save

        create_log_event
        update_seats_with_node

        true
      end
    end

    private

    def new_date
      @new_date ||= EventDate.find(@new_date_id)
    end

    def order
      @order ||= Order.find(@order_id)
    end

    def chosen_seats
      @chosen_seats ||= ChosenSeatsService.new(@socket_id)
    end

    def update_ticket(ticket)
      ticket.date = new_date
      ticket.seat = chosen_seats.next if seating?
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

    def enough_seats_available?
      new_date.number_of_available_seats >= tickets.count
    end

    def create_log_event
      log_service(order).transfer_tickets(updated_tickets, by_customer: @by_customer)
    end

    def update_seats_with_node
      NodeApi.update_seats(updated_seats) if seating?
    end

    def seating?
      new_date.event.seating?
    end
  end
end
