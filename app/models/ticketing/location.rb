# frozen_string_literal: true

module Ticketing
  class Location < ApplicationRecord
    has_many :events, dependent: :restrict_with_exception

    validates :name, :street, :postcode, :city, :coordinates, presence: true
  end
end
