# frozen_string_literal: true

FactoryBot.define do
  factory :member, class: 'Members::Member', parent: :user do
    first_name { 'John' }
    last_name { 'Doe' }
    gender { :female }
    sequence(:email) { |n| "member#{n}@example.com" }
    joined_at { Time.zone.today }

    trait :membership_fee_paid do
      membership_fee_paid_until { 1.month.from_now }
    end

    trait :membership_cancelled do
      membership_terminates_on { 1.month.from_now }
    end

    trait :with_sepa_mandate do
      association :sepa_mandate, factory: :members_sepa_mandate
    end
  end
end
