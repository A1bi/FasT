# frozen_string_literal: true

FactoryBot.define do
  factory :ticket_type, class: 'Ticketing::TicketType' do
    name { 'Sample type' }
    sequence(:price) { |n| 7 * n }
    event

    trait :free do
      name { 'Free' }
      price { 0 }
      availability { :exclusive }
    end
  end
end
