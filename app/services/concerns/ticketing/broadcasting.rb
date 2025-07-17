# frozen_string_literal: true

module Ticketing
  module Broadcasting
    extend ActiveSupport::Concern

    private

    def broadcast_tickets_sold(tickets: nil)
      BroadcastTicketsSoldJob.perform_later(tickets: tickets&.to_a)
    end
  end
end
