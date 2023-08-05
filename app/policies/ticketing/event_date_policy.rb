# frozen_string_literal: true

module Ticketing
  class EventDatePolicy < ApplicationPolicy
    def create?
      user_permitted?(:ticketing_events_update)
    end

    def update?
      create? && record.future? && !record.cancelled? && record.tickets.none?
    end

    def destroy?
      update?
    end

    def permitted_attributes
      %i[date]
    end
  end
end
