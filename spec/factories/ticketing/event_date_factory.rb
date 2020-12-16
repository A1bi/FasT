# frozen_string_literal: true

FactoryBot.define do
  factory :event_date, class: 'Ticketing::EventDate' do
    event
    date { FFaker::Time.between(1.week.from_now, 2.weeks.from_now) }
  end
end
