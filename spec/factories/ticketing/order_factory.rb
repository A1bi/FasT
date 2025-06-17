# frozen_string_literal: true

FactoryBot.define do
  factory :order, class: 'Ticketing::Order' do
    paid { true }

    trait :with_tickets do
      transient do
        event { association :event, :complete }
        date { nil }
        tickets_count { 1 }
      end

      before(:create) do |order, evaluator|
        seats = evaluator.event.seating? ? evaluator.event.seating.seats.to_a : []
        evaluator.tickets_count.times do
          order.tickets << create(:ticket, order:,
                                           date: evaluator.date || evaluator.event.dates.first,
                                           type: evaluator.event.ticket_types.first,
                                           seat: seats.pop)
        end
      end
    end

    trait :with_purchased_coupons do
      before(:create) do |order|
        order.purchased_coupons = create_list(:coupon, 2, :credit,
                                              purchased_with_order: order)
      end
    end

    trait :with_seating do
      transient do
        event { association :event, :complete, :with_seating, seats_count: tickets_count }
      end
    end

    trait :unpaid do
      paid { false }
      pay_method { :transfer }
    end

    trait :complete do
      with_purchased_coupons
    end

    trait :with_bank_refunds do
      after(:create) do |order|
        create_list(:bank_refund, 1, order:)
      end
    end

    trait :with_balance do
      after(:create) do |order|
        service = Ticketing::OrderBillingService.new(order)
        service.update_balance(:foo) {} # rubocop:disable Lint/EmptyBlock
      end
    end

    trait :with_credit do
      after(:create) do |order|
        order.billing_account.update(balance: 123)
      end
    end
  end
end
