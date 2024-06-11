# frozen_string_literal: true

FactoryBot.define do
  factory :geolocation, class: 'Ticketing::Geolocation' do
    postcode { FFaker::AddressDE.zip_code }
    cities { [FFaker::AddressDE.city] }
    coordinates { [FFaker::Geolocation.lat, FFaker::Geolocation.lng] }
  end
end
