module Api
  module Ticketing
    class OrdersController < ApplicationController
      include ::Ticketing::OrderingType

      def create
        unless authorized?
          return render_error('Unauthorized', status: :forbidden)
        end

        return render_error('Unknown type') unless type.in? %w[web admin retail]

        @order = create_order

        if @order.persisted?
          suppress_in_production(StandardError) do
            create_newsletter_subscriber
          end

          if admin?
            flash[:notice] = t(
              "ticketing.orders.created#{@order.email.present? ? '_email' : nil}"
            )
          end

          render json: { order: @order.api_hash(%i[tickets printable]) }

        else
          render_error('Invalid order', info: { errors: @order.errors.messages })
        end
      end

      private

      def create_order
        ::Ticketing::OrderCreateService.new(order_params, current_user).execute
      end

      def order_params
        params.permit(
          :type, :retail_store_id, :newsletter, :socket_id,
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
        cookie_name = "_#{Rails.application.class.parent_name}_retail_store_id"
        web? ||
          admin? && current_user&.admin? ||
          retail? && cookies.signed[cookie_name] == params[:retail_store_id]
      end

      def render_error(error, info: nil, status: :unprocessable_entity)
        Raven.capture_message(error, extra: info)
        render status: status, json: { error: error }
      end
    end
  end
end
