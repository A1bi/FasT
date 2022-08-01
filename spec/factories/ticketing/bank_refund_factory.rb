# frozen_string_literal: true

FactoryBot.define do
  factory :bank_refund, class: 'Ticketing::BankRefund' do
    name { 'John Doe' }
    iban { 'DE75512108001245126199' }
    association :order, factory: %i[order complete]

    trait :with_amount do
      amount { 15 }
    end

    trait :submitted do
      association :submission, factory: :bank_refund_submission
    end
  end
end
