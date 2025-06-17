# frozen_string_literal: true

FactoryBot.define do
  factory :block, class: 'Ticketing::Block' do
    seating
    sequence(:name) { |n| "Block #{n}" }

    trait :with_seats do
      transient { seats_count { 1 } }
      seats { build_list(:seat, seats_count) }
    end
  end
end
