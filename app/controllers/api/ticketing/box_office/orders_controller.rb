# frozen_string_literal: true

module Api
  module Ticketing
    module BoxOffice
      class OrdersController < BaseController
        include OrderCreation

        before_action :find_order, only: :destroy

        helper ::Ticketing::TicketingHelper

        def index
          # we exclude coupon orders, therefore date_id must be present
          @orders = ::Ticketing::Order.where.not(date_id: nil).order(:last_name, :first_name)
          return @orders = @orders.none unless %i[event_today unpaid q].any? { |key| params[key].present? }

          @orders = @orders.event_today if params[:event_today].present?
          @orders = @orders.unpaid if params[:unpaid].present?
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
