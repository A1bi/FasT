# frozen_string_literal: true

FactoryBot.define do
  factory :coupon, class: 'Ticketing::Coupon' do
    trait :with_free_tickets do
      free_tickets { 2 }
    end

    trait :with_value do
      transient { value { 25 } }

      after(:create) do |coupon, evaluator|
        coupon.deposit_into_account(evaluator.value, :foo)
      end
    end

    trait :with_credit do
      with_value
    end

    trait :expired do
      expires_at { Date.yesterday }
    end
  end
end
