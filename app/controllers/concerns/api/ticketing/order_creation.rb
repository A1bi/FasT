# frozen_string_literal: true

module Api
  module Ticketing
    module OrderCreation
      extend ActiveSupport::Concern

      included do
        rescue_from(::Ticketing::StripeBaseService::TransactionError) { head :payment_required }
      end

      private

      def create_order
        @order = order_create_service.execute
        report_invalid_order if order_errors?
      end

      def order_errors?
        order_create_service.errors?
      end

      def report_invalid_order
        Sentry.capture_message(
          'invalid order', extra: {
            service_errors: order_create_service.errors,
            validation_errors: @order.errors.messages
          }
        )
      end

      def order_create_service
        @order_create_service ||= ::Ticketing::OrderCreateService.new(
          order_params,
          current_user:,
          current_box_office:
        )
      end

      def current_box_office
        super if defined?(super)
      end
    end
  end
end
