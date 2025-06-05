# frozen_string_literal: true

module Ticketing
  module NodeUpdating
    extend ActiveSupport::Concern

    private

    def update_node_with_tickets(tickets)
      NodeApi.update_seats_from_records(tickets)
    end
  end
end
