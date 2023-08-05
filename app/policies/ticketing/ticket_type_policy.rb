# frozen_string_literal: true

module Ticketing
  class TicketTypePolicy < ApplicationPolicy
    def create?
      user_permitted?(:ticketing_events_update)
    end

    def update?
      create? && record.tickets.none?
    end

    def destroy?
      update?
    end

    def permitted_attributes
      %i[name price info availability vat_rate]
    end
  end
end
