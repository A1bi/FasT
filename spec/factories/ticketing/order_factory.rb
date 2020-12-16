# frozen_string_literal: true

FactoryBot.define do
  factory :order, class: 'Ticketing::Order' do
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

    trait :with_purchased_coupons do
      before(:create) do |order|
        order.purchased_coupons = create_list(:coupon, 2, :with_amount,
                                              purchased_with_order: order)
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
      with_purchased_coupons
    end
  end
end
