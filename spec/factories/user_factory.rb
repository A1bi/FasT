# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    password { SecureRandom.hex }

    trait :admin do
      group { :admin }
    end
  end
end
