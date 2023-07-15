# frozen_string_literal: true

module Ticketing
  class WebPushNotificationsJob < ApplicationJob
    def perform(subscription, data:)
      WebPush.payload_send(
        message: data.to_json,
        endpoint: subscription.endpoint,
        p256dh: subscription.p256dh,
        auth: subscription.auth,
        vapid: {
          subject: 'mailto:info@theater-kaisersesch.de',
          public_key: Rails.application.credentials.web_push[:public_key],
          private_key: Rails.application.credentials.web_push[:private_key]
        }
      )
    rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription, WebPush::Unauthorized
      subscription.destroy
    rescue WebPush::ResponseError => e
      raise unless e.response.is_a?(Net::HTTPBadRequest)

      subscription.destroy
    end
  end
end
