# frozen_string_literal: true

FactoryBot.define do
  factory :billing_account, class: Ticketing::Billing::Account do
    for_retail_store

    trait :for_retail_store do
      association :billable, factory: :retail_store
    end
  end
end
