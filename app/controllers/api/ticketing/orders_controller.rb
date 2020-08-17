# frozen_string_literal: true

module Api
  module Ticketing
    class OrdersController < ApiController
      include OrderCreation
      include ::Ticketing::OrderingType

      prepend_before_action :authorize_type

      def create
        return head :not_found unless type.in? %i[web admin retail]

        @order = create_order

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
            {
              tickets: {},
              coupon_codes: [],
              address: %i[
                email first_name gender last_name affiliation phone plz
              ],
              payment: %i[method name iban]
            }
          ],
          covid19: {
            attendees: %i[name street plz city phone]
          }
        )
      end

      def create_newsletter_subscriber
        return unless web? && params[:newsletter].present?

        Newsletter::SubscriberCreateService.new(newsletter_params,
                                                after_order: true).execute
      end

      def newsletter_params
        subscriber_params = @order.slice(:email, :gender, :last_name)
        subscriber_params[:privacy_terms] = true
        subscriber_params
      end

      def set_flash_notice
        return unless admin?

        key = ".created#{'_email' if @order.email.present?}"
        flash[:notice] = t(key)
      end

      def authorize_type
        return if type.blank? || web? || admin_action_authorized? ||
                  retail_action_authorized?

        deny_access root_path
      end

      def admin_action_authorized?
        admin? && current_user&.admin?
      end

      def retail_action_authorized?
        retail? && current_user&.retail?
      end
    end
  end
end
