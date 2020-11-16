# frozen_string_literal: true

FactoryBot.define do
  factory :seating, class: Ticketing::Seating do
    name { 'Seating' }
    number_of_seats { 30 }
  end
end
