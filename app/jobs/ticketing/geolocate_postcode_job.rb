# frozen_string_literal: true

module Ticketing
  class GeolocatePostcodeJob < ApplicationJob
    def perform(postcode)
      return if postcode.blank? || Geolocation.where(postcode:).any?

      location = Nominatim.cities_and_districts_for_postcode(postcode)
      return if location.blank?

      Geolocation.create!(
        **location.slice(:postcode, :cities, :districts),
        coordinates: location.values_at(:lat, :lon)
      )
    end
  end
end
