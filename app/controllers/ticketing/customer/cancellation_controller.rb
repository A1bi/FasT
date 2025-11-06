# frozen_string_literal: true

module Ticketing
  module Customer
    class CancellationController < BaseController
      helper TicketingHelper

      before_action :redirect_unauthenticated
      before_action :determine_transferability, only: :index

      def index; end
    end
  end
end
