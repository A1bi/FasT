# frozen_string_literal: true

module Ticketing
  class Reservation < ApplicationRecord
    belongs_to :seat, touch: true
    belongs_to :date, class_name: 'EventDate'
    belongs_to :group, class_name: 'ReservationGroup', touch: true

    def expired?
      return false if expires.nil?

      expires < Time.current
    end
  end
end
