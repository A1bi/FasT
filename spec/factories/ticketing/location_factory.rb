# frozen_string_literal: true

FactoryBot.define do
  factory :location, class: 'Ticketing::Location' do
    name { 'Test Location' }
    street { FFaker::AddressDE.street_address }
    postcode { FFaker::AddressDE.zip_code }
    city { FFaker::AddressDE.city }
    coordinates { [FFaker::Geolocation.lat, FFaker::Geolocation.lng] }
  end
end
