module Ticketing
  class Geolocation < BaseModel
    validates :postcode, :cities, :coordinates, presence: true
  end
end
