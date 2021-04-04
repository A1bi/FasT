# frozen_string_literal: true

FactoryBot.define do
  factory :seating, class: 'Ticketing::Seating' do
    name { 'Seating' }
    number_of_seats { 30 }

    trait :with_plan do
      plan_file_name { 'foo.svg' }
    end
  end
end
