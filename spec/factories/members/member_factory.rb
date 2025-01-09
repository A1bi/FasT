# frozen_string_literal: true

FactoryBot.define do
  factory :member, class: 'Members::Member', parent: :user do
    gender { :female }
    joined_at { Time.zone.today }

    trait :membership_fee_paid do
      membership_fee_paid_until { 1.month.from_now }
    end

    trait :membership_cancelled do
      membership_terminates_on { 1.month.from_now }
    end

    trait :membership_fee_payments_paused do
      membership_fee_payments_paused { true }
    end

    trait :with_sepa_mandate do
      sepa_mandate factory: :members_sepa_mandate
    end
  end
end
