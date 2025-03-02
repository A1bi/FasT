# frozen_string_literal: true

module Ticketing
  class TicketTypePolicy < ApplicationPolicy
    def create?
      user_permitted?(:ticketing_events_update)
    end

    def update?
      create?
    end

    def destroy?
      update?
    end

    def permitted_attributes
      if record.tickets.none?
        %i[name price info availability vat_rate]
      else
        %i[name info availability]
      end
    end
  end
end
