# frozen_string_literal: true

FactoryBot.define do
  factory :seat, class: 'Ticketing::Seat' do
    sequence(:number) { |n| n }
  end
end
