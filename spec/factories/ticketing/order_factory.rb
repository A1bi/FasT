# frozen_string_literal: true

FactoryBot.define do
  factory :order, class: Ticketing::Order do
    trait :with_tickets do
      transient do
        event { build(:event, :complete) }
        tickets_count { 1 }
      end

      before(:create) do |order, evaluator|
        order.tickets = create_list(:ticket, evaluator.tickets_count,
                                    order: order,
                                    date: evaluator.event.dates.first,
                                    type: evaluator.event.ticket_types.first)
      end
    end

    trait :paid do
      paid { true }

      after(:create) { |order| order.update(paid: true) }
    end

    trait :unpaid do
      after(:create) { |order| order.update(paid: false) }
    end

    trait :complete do
      with_tickets
    end
  end
end
