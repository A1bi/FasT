module Api
  module Ticketing
    module OrderCreation
      extend ActiveSupport::Concern

      private

      def create_order(retail_store: nil, box_office: nil)
        ::Ticketing::OrderCreateService.new(
          order_params,
          current_user: current_user,
          current_retail_store: retail_store,
          current_box_office: box_office
        ).execute
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
