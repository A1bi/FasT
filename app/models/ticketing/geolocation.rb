module Ticketing
  class Geolocation < ApplicationRecord
    validates :postcode, :cities, :coordinates, presence: true
  end
end
