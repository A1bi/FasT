# frozen_string_literal: true

module Ticketing
  class TicketCheckInJob < ApplicationJob
    def perform(ticket_id:, date:, medium:)
      @check_in = Ticket.find(ticket_id).check_ins.create!(date:, medium:)
      broadcast_check_in
    end

    private

    def broadcast_check_in
      BroadcastCheckInsJob.perform_later(check_ins: [@check_in])
    end
  end
end
