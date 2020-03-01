# frozen_string_literal: true

module Ticketing
  class OrderMailer < ApplicationMailer
    helper TicketingHelper

    before_action { @order = params[:order] }
    before_action :prepare_tickets

    default to: -> { @order.email }

    def confirmation
      mail
    end

    def pay_reminder
      mail if @order.transfer_payment? && !@order.paid
    end

    def payment_received
      mail
    end

    def resend_tickets
      mail
    end

    def cancellation
      @reason = params[:reason]
      mail
    end

    private

    def prepare_tickets
      @tickets = @order.tickets.cancelled(false)
      return unless attach_tickets?

      pdf = TicketsWebPdf.new
      pdf.add_tickets @tickets
      attachments['tickets.pdf'] = pdf.render
    end

    def attach_tickets?
      !@order.cancelled? && (@order.paid || @order.charge_payment?)
    end
    helper_method :attach_tickets?

    def overview_url
      @overview_url ||= order_overview_url(
        @order.signed_info(authenticated: true)
      )
    end
    helper_method :overview_url
  end
end
