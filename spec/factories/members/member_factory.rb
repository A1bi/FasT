# frozen_string_literal: true

FactoryBot.define do
  factory :member, class: 'Members::Member', parent: :user do
    first_name { 'John' }
    last_name { 'Doe' }
    joined_at { Time.zone.today }

    trait :membership_fee_paid do
      after(:create, &:renew_membership!)
    end

    trait :membership_cancelled do
      after(:create, &:terminate_membership!)
    end

    trait :with_sepa_mandate do
      association :sepa_mandate, factory: :members_sepa_mandate
    end
  end
end
