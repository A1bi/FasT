# frozen_string_literal: true

FactoryBot.define do
  factory :ticket, class: Ticketing::Ticket do
    order
    sequence(:order_index) { |n| n }
    association :type, factory: :ticket_type
    date factory: :event_date
  end
end
