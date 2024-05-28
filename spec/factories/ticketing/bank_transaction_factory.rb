# frozen_string_literal: true

FactoryBot.define do
  factory :bank_transaction, class: 'Ticketing::BankTransaction' do
    transient do
      refund { false }
    end

    name { 'John Doe' }
    iban { 'DE75512108001245126199' }
    order factory: %i[web_order with_purchased_coupons]

    trait :with_amount do
      amount { 15 * (refund ? -1 : 1) }
    end

    trait :submittable do
      with_amount
    end

    trait :submitted do
      with_amount
      submission factory: :bank_submission
    end

    trait :received do
      raw_source { { 'name' => 'foo', 'iban' => 'DE75512108001245126199', 'amount' => 123.45, 'date' => '2024-05-01' } }
      raw_source_sha { FFaker::Crypto.sha256 }
    end

    factory :bank_debit

    factory :bank_refund do
      refund { true }
    end
  end
end
