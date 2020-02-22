# frozen_string_literal: true

module Ticketing
  module PushNotifications
    class Device < ApplicationRecord
      serialize :settings

      validates :token, :app, presence: true
      validates :token, uniqueness: { scope: :app }

      def push(body: nil, title: nil, badge: nil, sound: nil)
        sound = nil if settings[:sound_enabled].blank?
        Ticketing::PushNotificationsJob.perform_later(
          self, body: body, title: title, badge: badge, sound: sound
        )
      end

      def topic
        Settings.apns.topics[app]
      end
    end
  end
end
