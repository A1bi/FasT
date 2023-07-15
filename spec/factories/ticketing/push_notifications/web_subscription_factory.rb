# frozen_string_literal: true

FactoryBot.define do
  factory :push_notifications_web_subscription, class: 'Ticketing::PushNotifications::WebSubscription' do
    endpoint { SecureRandom.hex }
    p256dh { SecureRandom.hex }
    auth { SecureRandom.hex }
    user
  end
end
