# frozen_string_literal: true

module Api
  module Ticketing
    module BoxOffice
      class OrdersController < BaseController
        include OrderCreation

        before_action :find_order, only: :destroy

        helper ::Ticketing::TicketingHelper

        def index
          @orders = ::Ticketing::Order.with_tickets.order(:last_name, :first_name)
          return @orders = @orders.none unless params.keys.intersect?(%w[event_today unpaid recent q])

          @orders = @orders.event_today if params[:event_today].present?
          @orders = @orders.unpaid if params[:unpaid].present?
          @orders = recent_orders if params[:recent].present?
          @orders, @ticket = search_orders if params[:q].present?
        end

        def show
          @order = ::Ticketing::Order.find(params[:id])
        end

        def create
          @order = create_order(box_office: current_box_office)
          return if @order.persisted?

          report_invalid_order
          head :bad_request
        end

        def destroy
          return head :forbidden unless @order.is_a? ::Ticketing::BoxOffice::Order

          ::Ticketing::OrderDestroyService.new(@order).execute
          head :no_content
        end

        private

        def find_order
          @order = ::Ticketing::Order.find(params[:id])
        end

        def recent_orders
          @orders.where(box_office_id: current_box_office).order(created_at: :desc).limit(30)
        end

        def search_orders
          ::Ticketing::OrderSearchService.new(
            params[:q],
            scope: @orders
          ).execute
        end

        def order_params
          params[:type] = :box_office
          params.permit(
            :type, :box_office_id, :socket_id,
            order: [
              :date,
              { tickets: {} }
            ]
          )
        end
      end
    end
  end
end
