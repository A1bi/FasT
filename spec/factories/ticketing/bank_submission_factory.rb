# frozen_string_literal: true

FactoryBot.define do
  factory :bank_submission, class: 'Ticketing::BankSubmission' do
    trait :with_debits do
      transient do
        transactions_count { 1 }
      end

      after(:create) do |submission, evaluator|
        submission.transactions = create_list(:bank_debit, evaluator.transactions_count, :with_amount, submission:)
      end
    end

    trait :with_refunds do
      after(:create) do |submission|
        submission.transactions << create(:bank_refund, :with_amount, submission:)
      end
    end
  end
end
