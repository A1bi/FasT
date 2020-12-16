# frozen_string_literal: true

FactoryBot.define do
  factory :retail_order, class: 'Ticketing::Retail::Order', parent: :order do
    store factory: :retail_store
  end
end
