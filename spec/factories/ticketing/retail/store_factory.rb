# frozen_string_literal: true

FactoryBot.define do
  factory :retail_store, class: 'Ticketing::Retail::Store' do
    sequence(:name) { |n| "Retail Store #{n}" }
    sale_enabled { true }

    trait :sale_disabled do
      sale_enabled { false }
    end
  end
end
