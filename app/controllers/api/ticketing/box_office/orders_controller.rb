module Api
  module Ticketing
    module BoxOffice
      class OrdersController < ApplicationController
        include OrderCreation

        skip_before_action :verify_authenticity_token

        def index
          @orders = ::Ticketing::Order
          @orders = @orders.event_today if params[:event_today].present?
          @orders = @orders.unpaid if params[:unpaid].present?
          @orders, @ticket = search_orders if params[:q].present?

          render_orders
        end

        def show
          @order = ::Ticketing::Order.find(params[:id])

          render_order
        end

        def create
          @order = create_order

          unless @order.persisted?
            report_invalid_order
            return head :bad_request
          end

          render_order
        end

        private

        def search_orders
          ::Ticketing::OrderSearchService.new(
            params[:q],
            search_base: @orders
          ).execute
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

        def render_orders
          render json: {
            ticket_id: @ticket&.id.to_s,
            orders: @orders.map { |o| info_for_order(o) }
          }
        end

        def render_order
          render json: {
            order: info_for_order(@order)
          }
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
