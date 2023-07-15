# frozen_string_literal: true

module Api
  module Ticketing
    module PushNotifications
      class SubscriptionsController < ApiController
        def create
          authorize ::Ticketing::PushNotifications::WebSubscription

          registration = ::Ticketing::PushNotifications::WebSubscription.find_or_create_by(
            **params.permit(:endpoint),
            **params.require(:keys).permit(:p256dh, :auth)
          )

          head registration.persisted? ? :no_content : :unprocessable_entity
        end
      end
    end
  end
end
