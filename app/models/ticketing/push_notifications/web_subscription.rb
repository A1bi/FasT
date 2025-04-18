# frozen_string_literal: true

module Ticketing
  module PushNotifications
    class WebSubscription < ApplicationRecord
      belongs_to :user, optional: false

      validates :endpoint, :p256dh, :auth, presence: true
      validates :endpoint, uniqueness: true

      def push(data)
        Ticketing::WebPushNotificationsJob.perform_later(self, data:)
      end
    end
  end
end
