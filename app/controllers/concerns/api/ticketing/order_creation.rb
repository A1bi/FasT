# frozen_string_literal: true

module Api
  module Ticketing
    module OrderCreation
      extend ActiveSupport::Concern

      private

      def create_order(box_office: nil)
        ::Ticketing::OrderCreateService.new(
          order_params,
          current_user:,
          current_box_office: box_office
        ).execute
      end

      def report_invalid_order
        Sentry.capture_message(
          'invalid order', extra: {
            errors: @order.errors.messages
          }
        )
      end
    end
  end
end
