# frozen_string_literal: true

module Ticketing
  module NodeUpdating
    extend ActiveSupport::Concern

    private

    def update_node_with_tickets(tickets)
      # create a copy because the tickets might be deleted after calling
      # the block
      tickets = tickets.to_a
      return if block_given? && !yield

      NodeApi.update_seats_from_records(tickets)
    end
  end
end
