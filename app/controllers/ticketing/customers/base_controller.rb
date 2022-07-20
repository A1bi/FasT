# frozen_string_literal: true

module Ticketing
  module Customers
    class BaseController < ApplicationController
      skip_authorization

      before_action :find_records

      private

      def find_records
        if signed_info.try(:ticket?)
          @ticket = Ticketing::Ticket.find(signed_info.ticket.id)
          @order = @ticket.order
        elsif signed_info.try(:order?)
          @order = Ticketing::Order.find(signed_info.order.id)
        else
          return redirect_to root_url
        end

        @authenticated = signed_info.authenticated.nonzero? || !web_order?
      end

      def signed_info
        @signed_info ||= Ticketing::SigningKey.verify_info(params[:signed_info])
      end

      def web_order?
        @order.is_a? Ticketing::Web::Order
      end

      def redirect_unauthenticated
        redirect_to order_overview_path(params[:signed_info]) unless @authenticated
      end
    end
  end
end
