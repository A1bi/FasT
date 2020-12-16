# frozen_string_literal: true

FactoryBot.define do
  factory :push_notifications_device,
          class: 'Ticketing::PushNotifications::Device' do
    token { SecureRandom.hex }
    settings { {} }

    trait :stats do
      app { :stats }
    end
  end
end
