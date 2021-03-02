# frozen_string_literal: true

FactoryBot.define do
  factory :retail_user, class: 'Ticketing::Retail::User', parent: :user do
    store factory: :retail_store
  end
end
