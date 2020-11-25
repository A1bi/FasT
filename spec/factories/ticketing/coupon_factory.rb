# frozen_string_literal: true

FactoryBot.define do
  factory :coupon, class: Ticketing::Coupon do
    trait :with_free_tickets do
      free_tickets { 2 }
    end

    trait :expired do
      expires { Date.yesterday }
    end
  end
end
