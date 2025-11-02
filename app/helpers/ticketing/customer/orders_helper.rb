# frozen_string_literal: true

module Ticketing
  module Customer
    module OrdersHelper
      def structured_data(order)
        tag.script type: 'application/ld+json' do
          raw render(partial: 'ticketing/customer/orders/structured_data', formats: :json, locals: { order: }) # rubocop:disable Rails/OutputSafety
        end
      end

      def reservation_status(ticket)
        schema_prefixed(ticket.cancelled? ? 'ReservationCancelled' : 'ReservationConfirmed')
      end

      def order_url(order)
        customer_order_overview_url(order.signed_info(authenticated: true))
      end

      def schema_prefixed(entity)
        "#{schema_context}/#{entity}"
      end

      def schema_context
        'http://schema.org'
      end
    end
  end
end
