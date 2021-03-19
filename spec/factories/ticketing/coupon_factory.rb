# frozen_string_literal: true

FactoryBot.define do
  factory :coupon, class: 'Ticketing::Coupon' do
    trait :with_free_tickets do
      free_tickets { 2 }
    end

    trait :with_credit do
      transient { credit { 25 } }

      after(:create) do |coupon, evaluator|
        coupon.deposit_into_account(evaluator.credit, :foo)
      end
    end

    trait :expired do
      expires_at { Date.yesterday }
    end
  end
end
