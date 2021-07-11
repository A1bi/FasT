# frozen_string_literal: true

class Nominatim
  include HTTParty
  base_uri 'https://nominatim.openstreetmap.org'

  class << self
    def cities_and_districts_for_postcode(postcode, country: 'DE')
      places = places_for_postcode(postcode,
                                   country: country, address_details: true)
      return if places.empty?

      info = {
        **places.first.slice(:lat, :lon, :country_code),
        postcode: postcode,
        cities: [],
        districts: []
      }

      places.each do |place|
        address = place[:address]
        info[:cities] << address.values_at(:city, :town, :village, :municipality).compact.first
        info[:districts] << address.values_at(:suburb, :city_district).compact.first
      end

      %i[cities districts].each { |key| info[key] = info[key].compact.uniq }
      info
    end

    def places_for_postcode(postcode, country: 'DE', address_details: false)
      get('/search', postalcode: postcode, country: country,
                     addressdetails: address_details)
    end

    private

    def get(path, params = {})
      params[:format] = 'json'
      response = super(path, query: params)

      raise 'Error' if response.code >= 400

      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
