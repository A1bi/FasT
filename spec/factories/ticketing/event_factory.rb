# frozen_string_literal: true

FactoryBot.define do
  factory :event, class: 'Ticketing::Event' do
    name { 'Event' }
    sequence(:identifier) { |n| "event_#{n}" }
    sequence(:slug) { |n| "event-#{n}" }
    location { 'Sample location' }
    admission_duration { 60 }
    seating

    trait :with_dates do
      transient { dates_count { 1 } }
      dates { Array.new(dates_count) { association :event_date } }
    end

    trait :with_ticket_types do
      transient { ticket_types_count { 1 } }
      ticket_types do
        ticket_types_count.times.map do |i|
          association :ticket_type, price: 7 * (i + 1)
        end
      end
    end

    trait :with_free_ticket_type do
      after(:create) do |event|
        create(:ticket_type, :free, event: event)
      end
    end

    trait :with_seating_plan do
      association :seating, :with_plan
    end

    trait :complete do
      with_dates
      with_ticket_types
    end
  end
end
