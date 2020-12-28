# frozen_string_literal: true

FactoryBot.define do
  factory :membership_fee_payment, class: 'Members::MembershipFeePayment' do
    member
    amount { rand(10..50) }
    paid_until { 1.year.from_now }

    trait :submitted do
      debit_submission factory: :membership_fee_debit_submission
    end

    trait :with_sepa_mandate do
      association :member, :with_sepa_mandate
    end
  end
end
