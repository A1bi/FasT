module Api
  module Ticketing
    module BoxOffice
      class OrdersController < ApplicationController
        include OrderCreation

        skip_before_action :verify_authenticity_token

        def index
          orders, ticket = search_orders

          render json: {
            ticket_id: ticket&.id.to_s,
            orders: orders.map { |o| info_for_order(o) }
          }
        end

        def create
          @order = create_order

          unless @order.persisted?
            report_invalid_order
            return head :bad_request
          end

          render json: {
            order: info_for_order(@order)
          }
        end

        private

        def search_orders
          ::Ticketing::OrderSearchService.new(params[:q]).execute
        end

        def order_params
          params[:type] = :box_office
          params.permit(
            :type, :box_office_id, :socket_id,
            order: [
              :date,
              tickets: {}
            ]
          )
        end

        def info_for_order(order)
          order.api_hash(
            %i[personal log_events tickets status billing], %i[status]
          )
        end
      end
    end
  end
end
