# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    password { SecureRandom.hex }
    sequence(:email) { |n| "member#{n}@example.com" }
    first_name { FFaker::NameDE.first_name }
    last_name { FFaker::NameDE.last_name }

    trait :admin do
      group { :admin }
    end
  end
end
