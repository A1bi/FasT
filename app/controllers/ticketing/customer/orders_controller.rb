# frozen_string_literal: true

module Ticketing
  module Customer
    class OrdersController < BaseController
      skip_authorization

      before_action :redirect_unauthenticated, except: %i[show check_email]
      before_action :determine_transferability, only: :show
      before_action :determine_cancellability, only: :show

      helper Ticketing::TicketingHelper

      def show
        render :email_form unless @authenticated
      end

      def check_email
        return redirect_to authenticated_overview_path if email_correct?

        redirect_to request.path, alert: t('.wrong_email')
      end

      def passbook_pass
        send_file @ticket.passbook_pass(create: true).file_path, type: 'application/vnd.apple.pkpass'
      end

      def seats
        render json: seats_hash
      end

      private

      def seats_hash
        types = [[:chosen, @order], [:taken, @order.date]]
        types.each_with_object({}) do |type, obj|
          obj[type.first] = type.last.tickets.where(invalidated: false)
                                .filter_map(&:seat_id)
        end
      end

      def email_correct?
        web_order? && @order.email.present? && @order.email == params[:email]
      end

      def authenticated_overview_path
        customer_order_overview_path(@order.signed_info(authenticated: true))
      end

      def tickets_accessible?
        @order.paid?
      end
      helper_method :tickets_accessible?
    end
  end
end
