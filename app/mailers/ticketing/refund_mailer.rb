# frozen_string_literal: true

module Ticketing
  class RefundMailer < ApplicationMailer
    helper TicketingHelper

    default to: -> { @order.email }
    layout 'ticketing/order_mailer'

    def notification
      @order = params[:order]
      mail
    end

    private

    def overview_url
      @overview_url ||= order_overview_url(
        @order.signed_info(authenticated: true)
      )
    end
    helper_method :overview_url
  end
end
