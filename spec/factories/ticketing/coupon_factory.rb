# frozen_string_literal: true

FactoryBot.define do
  factory :coupon, class: 'Ticketing::Coupon' do
    free_tickets

    after(:create) do |coupon, evaluator|
      coupon.deposit_into_account(evaluator.value, :foo)
    end

    trait :free_tickets do
      value_type { :free_tickets }
      transient { value { 2 } }
    end

    trait :credit do
      value_type { :credit }
      transient { value { 25 } }
    end

    trait :blank do
      transient { value { 0 } }
    end

    trait :expired do
      expires_at { Date.yesterday }
    end
  end
end
