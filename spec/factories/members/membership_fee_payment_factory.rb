# frozen_string_literal: true

FactoryBot.define do
  factory :membership_fee_payment, class: 'Members::MembershipFeePayment' do
    member
    amount { 25 }
    paid_until { 1.year.from_now }

    trait :submitted do
      after(:create) do |payment|
        payment.create_debit_submission
        payment.save
      end
    end
  end
end
