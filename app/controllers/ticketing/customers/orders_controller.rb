# frozen_string_literal: true

module Ticketing
  module Customers
    class OrdersController < BaseController
      skip_authorization

      before_action :redirect_unauthenticated, except: %i[show check_email]

      WALLET_PATTERN = /(Android|iP(hone|ad|od)|OS X|Windows Phone)/

      helper Ticketing::TicketingHelper

      def show
        return render :email_form unless @authenticated

        @cancellable = web_order? && cancellable_tickets.any?
        @refundable = @cancellable && credit_after_cancellation?
        @transferable = transferable_tickets.any?
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

      def cancel
        return redirect_to_order_overview if cancellable_tickets.none?

        refund_params = params.permit(:name, :iban)
        refund_params[:use_most_recent] = params[:use_most_recent] == 'true'

        unless !credit_after_cancellation? || @order.stripe_payment? || refund_params[:use_most_recent] ||
               BankTransaction.new(order: @order, **params.permit(:name, :iban)).valid?
          return redirect_to_order_overview alert: t('.incorrect_bank_details')
        end

        Ticketing::TicketCancelService.new(cancellable_tickets, reason: :self_service).execute(refund: refund_params)

        redirect_to_order_overview notice: t('.tickets_cancelled')
      end

      private

      def cancellable_tickets
        valid_tickets.filter(&:customer_cancellable?)
      end

      def transferable_tickets
        valid_tickets.filter(&:customer_transferable?)
      end

      def credit_after_cancellation?
        @credit_after_cancellation ||= begin
          refundable_sum = cancellable_tickets.sum(&:price)
          (@order.balance + refundable_sum).positive?
        end
      end

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
        order_overview_path(@order.signed_info(authenticated: true))
      end

      def show_wallet?
        @show_wallet ||= request.user_agent&.match?(WALLET_PATTERN)
      end
      helper_method :show_wallet?
    end
  end
end
