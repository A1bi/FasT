# frozen_string_literal: true

FactoryBot.define do
  factory :coupon, class: 'Ticketing::Coupon' do
    with_free_tickets

    trait :with_value do
      transient { value { 25 } }

      after(:create) do |coupon, evaluator|
        coupon.deposit_into_account(evaluator.value, :foo)
      end
    end

    trait :with_free_tickets do
      value_type { :free_tickets }
      value { 2 }
      with_value
    end

    trait :with_credit do
      value_type { :credit }
      value { 25 }
      with_value
    end

    trait :blank do
      value { 0 }
    end

    trait :expired do
      expires_at { Date.yesterday }
    end
  end
end
