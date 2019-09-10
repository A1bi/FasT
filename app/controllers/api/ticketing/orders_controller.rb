module Api
  module Ticketing
    class OrdersController < ApplicationController
      include OrderCreation
      include ::Ticketing::RetailStoreAuthenticatable
      include ::Ticketing::OrderingType

      def create
        return head :not_found unless type.in? %i[web admin retail]
        return head :forbidden unless authorized?

        @order = create_order(retail_store: current_retail_store)

        unless @order.persisted?
          report_invalid_order
          return head :bad_request
        end

        suppress_in_production(StandardError) do
          create_newsletter_subscriber
        end

        set_flash_notice
      end

      private

      def order_params
        params.permit(
          :type, :newsletter, :socket_id,
          order: [
            %i[date ignore_free_tickets],
            tickets: {},
            coupon_codes: [],
            address: %i[
              email first_name gender last_name affiliation phone plz
            ],
            payment: %i[method name iban]
          ]
        )
      end

      def create_newsletter_subscriber
        return unless web? && params[:newsletter].present?

        Newsletter::SubscriberCreateService.new(newsletter_params, true).execute
      end

      def newsletter_params
        subscriber_params = @order.slice(:email, :gender, :last_name)
        subscriber_params[:privacy_terms] = true
        subscriber_params
      end

      def authorized?
        web? ||
          admin? && current_user&.admin? ||
          retail? && retail_store_signed_in?
      end

      def set_flash_notice
        return unless admin?

        key = '.created'
        key += '_email' if @order.email.present?
        flash[:notice] = t(key)
      end
    end
  end
end
