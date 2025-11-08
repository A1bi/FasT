# frozen_string_literal: true

module Ticketing
  module Customer
    class CancellationController < BaseController
      helper TicketingHelper

      before_action :redirect_unauthenticated
      before_action :determine_transferability, only: :index

      def index; end

      def refund_amount
        render json: {
          amount: simulation_service.refund_amount
        }
      end

      private

      def simulation_service
        TicketCancelSimulationService.new(tickets_to_cancel)
      end

      def tickets_to_cancel
        cancellable_tickets.where(id: params[:ticket_ids])
      end
    end
  end
end
