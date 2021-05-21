# frozen_string_literal: true

module Ticketing
  class Covid19CheckInMailer < ApplicationMailer
    default to: -> { @order.email }
    layout 'ticketing/order_mailer'

    def check_in(ticket)
      @ticket = ticket
      return unless (@order = ticket.order).is_a?(Web::Order) &&
                    ticket.event.covid19_presence_tracing?

      @check_in_url = ticket.date.covid19_check_in_url
      mail
    end
  end
end
