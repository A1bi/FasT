# frozen_string_literal: true

module Ticketing
  class Covid19CheckInMailer < ApplicationMailer
    default to: -> { @order.email }
    layout 'ticketing/order_mailer'

    def check_in(ticket)
      @ticket = ticket
      return unless (@order = ticket.order).is_a?(Web::Order) &&
                    Settings.covid19.presence_tracing_email &&
                    ticket.date.covid19_check_in_url.present?

      @check_in_url = ticket.date.covid19_check_in_url
      mail
    end
  end
end
