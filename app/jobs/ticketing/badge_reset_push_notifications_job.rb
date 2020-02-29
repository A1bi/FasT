# frozen_string_literal: true

module Ticketing
  class BadgeResetPushNotificationsJob < ApplicationJob
    def perform
      devices.find_each do |device|
        device.push(notification_data)
      end
    end

    private

    def devices
      Ticketing::PushNotifications::Device.where(app: :stats)
    end

    def notification_data
      { badge: 0 }
    end
  end
end
