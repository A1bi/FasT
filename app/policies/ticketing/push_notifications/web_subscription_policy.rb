# frozen_string_literal: true

module Ticketing
  module PushNotifications
    class WebSubscriptionPolicy < ApplicationPolicy
      def create?
        user_admin?
      end
    end
  end
end
