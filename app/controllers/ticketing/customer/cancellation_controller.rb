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
          amount: rand(10..1000)
        }
      end
    end
  end
end
