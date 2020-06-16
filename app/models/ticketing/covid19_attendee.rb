# frozen_string_literal: true

module Ticketing
  class Covid19Attendee < ApplicationRecord
    belongs_to :ticket

    auto_strip_attributes :name, :street, :plz, :city, squish: true
    phony_normalize :phone, default_country_code: 'DE'

    validates :ticket, :name, :street, :plz, :city, :phone, presence: true
    validates :plz, format: { with: /\A\d{5}\z/ }
  end
end
