# frozen_string_literal: true

module Ticketing
  module StatisticsHelpers
    def create_orders(geolocation_index, count)
      create_list(:web_order, count, :complete, plz: geolocations[geolocation_index].postcode)
    end

    def location_response(geolocation_index, orders_count)
      {
        **geolocations[geolocation_index].slice(:postcode, :cities, :districts),
        'coordinates' => geolocations[geolocation_index].coordinates.to_a.reverse,
        'orders' => orders_count
      }
    end
  end
end

RSpec.configure do |config|
  config.include Ticketing::StatisticsHelpers
end
