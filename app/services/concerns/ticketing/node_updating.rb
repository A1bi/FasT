module Ticketing
  module NodeUpdating
    extend ActiveSupport::Concern

    private

    def update_node_with_tickets(tickets)
      # create a copy because the tickets might be deleted after calling
      # the block
      tickets = tickets.to_a
      return false if block_given? && !yield

      NodeApi.update_seats_from_records(tickets)
      true
    end
  end
end
