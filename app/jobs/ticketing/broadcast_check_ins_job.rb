# frozen_string_literal: true

module Ticketing
  class BroadcastCheckInsJob < ApplicationJob
    def perform(check_ins: nil)
      # can't use check_ins.where here because check_ins might be an array instead of collection
      return if date.nil? || (check_ins.present? && check_ins.none? { |t| t.ticket.date == date })

      ActionCable.server.broadcast :ticketing_check_ins, check_ins_payload
    end

    private

    def check_ins_payload
      {
        check_ins: CheckIn.where(ticket: date.tickets.valid).select(:ticket_id).distinct.count
      }
    end

    def date
      @date ||= EventDate.imminent
    end
  end
end
