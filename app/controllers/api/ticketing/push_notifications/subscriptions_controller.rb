# frozen_string_literal: true

module Api
  module Ticketing
    module PushNotifications
      class SubscriptionsController < ApiController
        def create
          authorize ::Ticketing::PushNotifications::WebSubscription

          registration = ::Ticketing::PushNotifications::WebSubscription.find_or_create_by(
            **params.permit(:endpoint),
            **params.expect(keys: %i[p256dh auth]),
            user: current_user
          )

          head registration.persisted? ? :no_content : :unprocessable_entity
        end
      end
    end
  end
end
