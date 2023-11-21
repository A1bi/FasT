# frozen_string_literal: true

module Ticketing
  class EventPolicy < ApplicationPolicy
    def index?
      user_permitted?(:ticketing_events_read)
    end

    def show?
      index?
    end

    def update?
      user_permitted?(:ticketing_events_update)
    end

    def create?
      update?
    end

    def permitted_attributes
      [
        :name, :identifier, :assets_identifier, :slug, :location_id, :seating_id, :number_of_seats,
        :sale_start, :admission_duration, :ticketing_enabled,
        { info: %i[archived subtitle main_gallery_id header_gallery_id external_sale_url] }
      ]
    end
  end
end
