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

        refundable_sum = refundable_tickets.sum(&:price)
        balance_after_refund = @order.balance + refundable_sum
        changeable = @order.is_a?(Ticketing::Web::Order) && valid_tickets.any?
        @order_refundable = changeable && balance_after_refund.positive?
        @transferable = changeable && @order.date.date.future? && @event.dates.upcoming.any?
      end

      def check_email
        return redirect_to authenticated_overview_path if email_correct?

        redirect_to request.path, alert: t('.wrong_email')
      end

      def passbook_pass
        return head :forbidden if @ticket.blank?

        send_file @ticket.passbook_pass(create: true).file_path,
                  type: 'application/vnd.apple.pkpass'
      end

      def seats
        render json: seats_hash
      end

      def refund
        return redirect_to_order_overview if refundable_tickets.none?

        if web_order? && @order.charge_payment? &&
           params[:use_bank_charge] == 'true'
          bank_details = @order.bank_charge.slice(:name, :iban)

        else
          if params[:name].blank? || !IBANTools::IBAN.valid?(params[:iban])
            return redirect_to_order_overview alert: t('.incorrect_bank_details')
          end

          bank_details = params.permit(:name, :iban).to_h
        end

        bank_details[:iban].delete!(' ')

        Ticketing::TicketCancelService.new(refundable_tickets, reason: :date_cancelled)
                                      .execute(send_customer_email: false)

        mailer = Ticketing::RefundMailer.with(order: @order,
                                              **bank_details.symbolize_keys)
        mailer.customer.deliver_later
        mailer.internal.deliver_later

        redirect_to_order_overview notice: t('.refund_requested')
      end

      private

      def refundable_tickets
        valid_tickets.filter(&:refundable?)
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
