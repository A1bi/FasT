# frozen_string_literal: true

FactoryBot.define do
  factory :retail_store, class: Ticketing::Retail::Store do
    sequence(:name) { |n| "Retail Store #{n}" }
  end
end
