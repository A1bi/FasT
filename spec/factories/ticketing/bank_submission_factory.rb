# frozen_string_literal: true

FactoryBot.define do
  factory :bank_submission, class: 'Ticketing::BankSubmission' do
    trait :with_debits do
      after(:create) do |submission|
        submission.transactions << create(:bank_debit, :with_amount, submission:)
      end
    end

    trait :with_refunds do
      after(:create) do |submission|
        submission.transactions << create(:bank_refund, :with_amount, submission:)
      end
    end
  end
end
