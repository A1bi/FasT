module Api
  module Ticketing
    module BoxOffice
      class OrdersController < ApplicationController
        include OrderCreation

        def create
          @order = create_order

          return if @order.persisted?

          report_invalid_order
          head :bad_request
        end

        private

        def order_params
          params.permit(
            :box_office_id, :socket_id,
            order: [
              :date,
              tickets: {}
            ]
          )
          params[:type] = :box_office
        end
      end
    end
  end
end
