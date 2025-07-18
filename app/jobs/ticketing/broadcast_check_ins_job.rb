# frozen_string_literal: true

module Ticketing
  class BroadcastCheckInsJob < ApplicationJob
    def perform(check_ins: nil)
      # can't use check_ins.where here because check_ins might be an array instead of collection
      return if date.nil? || (check_ins.present? && check_ins.none? { |t| t.ticket.date == date })

      ActionCable.server.broadcast(:ticketing_check_ins, { check_ins: check_ins_count })
      ActionCable.server.broadcast(:ticketing_seats_checked_in, { checked_in_seat_ids: })
    end

    private

    def check_ins_count
      unique_check_ins.count
    end

    def checked_in_seat_ids
      return [] unless date.event.seating?

      Ticket.find(unique_check_ins.pluck(:ticket_id)).pluck(:seat_id)
    end

    def unique_check_ins
      @unique_check_ins ||= CheckIn.where(ticket: date.tickets.valid).select(:ticket_id).distinct
    end

    def date
      @date ||= EventDate.imminent
    end
  end
end
