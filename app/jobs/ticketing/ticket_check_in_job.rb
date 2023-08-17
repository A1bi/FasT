# frozen_string_literal: true

module Ticketing
  class TicketCheckInJob < ApplicationJob
    def perform(ticket_id:, date:, medium:)
      Ticket.find(ticket_id).check_ins.create!(date:, medium:)
    end
  end
end
