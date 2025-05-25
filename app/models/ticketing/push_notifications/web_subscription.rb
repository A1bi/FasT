# frozen_string_literal: true

module Ticketing
  module PushNotifications
    class WebSubscription < ApplicationRecord
      belongs_to :user, optional: false

      validates :endpoint, :p256dh, :auth, presence: true
      validates :endpoint, uniqueness: true

      def push(notification)
        Ticketing::WebPushNotificationsJob.perform_later(self, notification:)
      end
    end
  end
end
