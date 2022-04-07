# frozen_string_literal: true

module Ticketing
  class BadgeResetPushNotificationsJob < ApplicationJob
    def perform
      devices.find_each do |device|
        device.push(badge: 0)
      end
    end

    private

    def devices
      Ticketing::PushNotifications::Device.where(app: :stats)
    end
  end
end
