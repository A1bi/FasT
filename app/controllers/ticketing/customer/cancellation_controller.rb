# frozen_string_literal: true

module Ticketing
  module Customer
    class CancellationController < BaseController
      helper TicketingHelper

      before_action :redirect_unauthenticated
      before_action :determine_transferability, only: :index

      def index; end

      def refund
        render json: {
          cancelled_value: simulation_service.cancelled_value,
          refund_amount:
        }
      end

      def cancel
        return redirect_to_order_overview if tickets_to_cancel.none?

        unless !refund_amount.positive? || @order.try(:stripe_payment?) || refund_params[:use_most_recent] ||
               @order.bank_transactions.new(**params.permit(:name, :iban)).valid?
          return redirect_to_order_overview alert: t('.incorrect_bank_details')
        end

        TicketCancelService.new(tickets_to_cancel, reason: :self_service).execute(refund: refund_params)

        redirect_to_order_overview notice: t('.tickets_cancelled')
      end

      private

      def refund_amount
        simulation_service.refund_amount
      end

      def simulation_service
        @simulation_service ||= TicketCancelSimulationService.new(tickets_to_cancel)
      end

      def tickets_to_cancel
        @tickets_to_cancel ||= cancellable_tickets.where(id: params[:ticket_ids])
      end

      def refund_params
        @refund_params = begin
          refund_params = params.permit(:name, :iban)
          refund_params[:use_most_recent] = params[:use_most_recent] == 'true'
          refund_params
        end
      end
    end
  end
end
