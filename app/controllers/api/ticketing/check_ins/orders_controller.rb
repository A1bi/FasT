# frozen_string_literal: true

module Api
  module Ticketing
    module CheckIns
      class OrdersController < ApiController
        include Authenticatable

        def index
          @orders = ::Ticketing::Order.with_tickets.date_imminent
        end

        private

        def auth_token
          super || Rails.application.credentials.ticketing_api_auth_token
        end
      end
    end
  end
end
