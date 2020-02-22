# frozen_string_literal: true

module Passbook
  module Models
    class Registration < ActiveRecord::Base
      belongs_to :device
      belongs_to :pass

      def token
        device.push_token
      end

      def topic
        pass.type_id
      end

      def push
        Ticketing::PushNotificationsJob.perform_later(
          self, force_production_gateway: true
        )
      end
    end
  end
end
