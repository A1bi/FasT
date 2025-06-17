# frozen_string_literal: true

FactoryBot.define do
  factory :seating, class: 'Ticketing::Seating' do
    name { 'Seating' }
    plan_file_name { 'foo.svg' }

    trait :with_seats do
      transient { seats_count { 1 } }
      blocks { create_list(:block, 1, :with_seats, seats_count:) }
    end
  end
end
