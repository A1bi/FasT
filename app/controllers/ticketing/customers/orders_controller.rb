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

        @cancellable = web_order? && refundable_tickets.any?
        @refundable = @cancellable && credit_after_cancellation?
        @transferable = transferable
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
        return redirect_to_order_overview if refundable_tickets.none?

        if credit_after_cancellation?
          refund = @order.bank_refunds.create(bank_details)
          return redirect_to_order_overview alert: t('.incorrect_bank_details') unless refund.valid?
        end

        Ticketing::TicketCancelService.new(refundable_tickets, reason: :date_cancelled)
                                      .execute(send_customer_email: !credit_after_cancellation?)

        Ticketing::RefundMailer.with(refund:).customer.deliver_later if credit_after_cancellation?

        redirect_to_order_overview notice: t('.tickets_cancelled')
      end

      private

      def refundable_tickets
        valid_tickets.filter(&:refundable?)
      end

      def credit_after_cancellation?
        @credit_after_cancellation ||= begin
          refundable_sum = refundable_tickets.sum(&:price)
          (@order.balance + refundable_sum).positive?
        end
      end

      def transferable
        web_order? && valid_tickets.any? &&
          ((@order.date.cancelled? && @order.event.dates.uncancelled.upcoming.any?) ||
            (!@order.date.cancelled? && @order.date.admission_time.future?))
      end

      def bank_details
        if web_order? && @order.charge_payment? && params[:use_bank_charge] == 'true'
          @order.bank_charge.slice(:name, :iban)
        else
          params.permit(:name, :iban)
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
        @show_wallet ||= request.user_agent.match(WALLET_PATTERN).present?
      end
      helper_method :show_wallet?
    end
  end
end
