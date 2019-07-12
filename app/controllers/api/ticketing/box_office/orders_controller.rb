module Api
  module Ticketing
    module BoxOffice
      class OrdersController < ApplicationController
        include OrderCreation

        skip_before_action :verify_authenticity_token

        def create
          @order = create_order

          if @order.persisted?
            return render json: {
              order: @order.api_hash(
                %i[personal log_events tickets status billing], %i[status]
              )
            }
          end

          report_invalid_order
          head :bad_request
        end

        private

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
      end
    end
  end
end
