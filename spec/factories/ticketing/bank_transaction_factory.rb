# frozen_string_literal: true

FactoryBot.define do
  factory :bank_transaction, class: 'Ticketing::BankTransaction' do
    transient do
      refund { false }
      bank_reference { 'foo' }
    end

    name { 'John Doe' }
    iban { 'DE75512108001245126199' }

    trait :with_orders do
      transient do
        orders_count { 1 }
      end

      before(:create) do |transaction, evaluator|
        transaction.orders = create_list(:web_order, evaluator.orders_count, :with_purchased_coupons)
      end
    end

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
      camt_source { { 'Amt' => 123, 'AcctSvcrRef' => bank_reference, 'BookgDt' => { 'Dt' => '2025-12-17' } } }
    end

    factory :bank_debit

    factory :bank_refund do
      refund { true }
    end
  end
end
