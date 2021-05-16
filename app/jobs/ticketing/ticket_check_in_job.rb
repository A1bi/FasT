# frozen_string_literal: true

module Ticketing
  class TicketCheckInJob < ApplicationJob
    def perform(ticket_id:, date:, medium:)
      @ticket = Ticket.find(ticket_id)
      send_check_in_email
      create_check_ins(date, medium)
    end

    private

    def send_check_in_email
      return unless @ticket.event.covid19_presence_tracing? &&
                    no_check_ins_for_date?

      Covid19CheckInMailer.check_in(@ticket).deliver_later
    end

    def create_check_ins(date, medium)
      tickets_to_check_in.each do |t|
        t.check_ins.create!(date: date, medium: medium)
      end
    end

    def tickets_to_check_in
      @ticket.event.covid19? ? @ticket.order.tickets.valid : [@ticket]
    end

    def no_check_ins_for_date?
      @ticket.order.tickets.includes(:check_ins)
             .where(date_id: @ticket.date_id).where.not(check_ins: { id: nil })
             .none?
    end
  end
end
