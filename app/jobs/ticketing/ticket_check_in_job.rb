# frozen_string_literal: true

module Ticketing
  class TicketCheckInJob < ApplicationJob
    def perform(ticket_id:, date:, medium:)
      @ticket = Ticket.find(ticket_id)
      lock_order do
        send_check_in_email(date)
        create_check_ins(date, medium)
      end
    end

    private

    def send_check_in_email(date)
      return unless covid19_presence_tracing_email? &&
                    no_check_ins_for_date? && early_enough_for_email?

      Covid19CheckInMailer.check_in(@ticket).deliver_later(
        wait_until: 1.minute.after(Time.zone.parse(date))
      )
    end

    def create_check_ins(date, medium)
      tickets_to_check_in.each do |t|
        t.check_ins.create!(date: date, medium: medium)
      end
    end

    def tickets_to_check_in
      @ticket.event.covid19? ? @ticket.order.tickets.valid : [@ticket]
    end

    def covid19_presence_tracing_email?
      Settings.covid19.presence_tracing_email && @ticket.event.covid19?
    end

    def no_check_ins_for_date?
      @ticket.order.tickets.includes(:check_ins)
             .where(date_id: @ticket.date_id).where.not(check_ins: { id: nil })
             .none?
    end

    def early_enough_for_email?
      1.hour.after(@ticket.date.date).future?
    end

    def lock_order(&block)
      # acquire exclusive lock on order to avoid sending multiple emails to the
      # same person when multiple jobs with sibling tickets run in parallel
      @ticket.order.with_lock(true, &block)
    end
  end
end
