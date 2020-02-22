# frozen_string_literal: true

module Ticketing
  class Geolocation < ApplicationRecord
    validates :postcode, :cities, :coordinates, presence: true
  end
end
