# frozen_string_literal: true

FactoryBot.define do
  factory :ticket_type, class: 'Ticketing::TicketType' do
    name { 'Sample type' }
    price { rand(1.0..50).floor(2) }
    event

    trait :free do
      name { 'Free' }
      price { 0 }
      availability { :exclusive }
    end
  end
end
