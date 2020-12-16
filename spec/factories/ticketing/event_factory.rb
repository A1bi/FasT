# frozen_string_literal: true

FactoryBot.define do
  factory :event, class: 'Ticketing::Event' do
    name { 'Event' }
    sequence(:identifier) { |n| "event_#{n}" }
    sequence(:slug) { |n| "event-#{n}" }
    location { 'Sample location' }
    seating

    trait :with_dates do
      transient { dates_count { 1 } }
      dates { Array.new(dates_count) { association :event_date } }
    end

    trait :with_ticket_types do
      transient { ticket_types_count { 1 } }
      ticket_types do
        Array.new(ticket_types_count) { association :ticket_type }
      end
    end

    trait :complete do
      with_dates
      with_ticket_types
    end
  end
end
