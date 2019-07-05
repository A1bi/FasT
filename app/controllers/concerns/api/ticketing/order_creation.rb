module Api
  module Ticketing
    module OrderCreation
      extend ActiveSupport::Concern

      private

      def create_order
        ::Ticketing::OrderCreateService.new(order_params, nil).execute
      end

      def report_invalid_order
        Raven.capture_message(
          'invalid order', extra: {
            errors: @order.errors.messages
          }
        )
      end
    end
  end
end
