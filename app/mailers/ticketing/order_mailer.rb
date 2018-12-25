module Ticketing
  class OrderMailer < BaseMailer
    helper TicketingHelper

    def order_action(action, order, options = nil)
      @order = order

      find_tickets
      attach_tickets if should_attach_tickets?

      should_mail = options&.any? ? send(action, options.symbolize_keys) : send(action)

      return if should_mail == false || @order.email.nil?
      mail  to: @order.email,
            subject: t(:subject, scope: [mailer_name, action]),
            template_name: action
    end

    private

    def confirmation
    end

    def payment_received
    end

    def overview
    end

    def pay_reminder
      @order.transfer_payment? && !@order.paid
    end

    def cancellation(reason: nil)
      @reason = reason
    end

    def resend_tickets
    end

    def seating_migration; end

    def find_tickets
      @tickets ||= @order.tickets.cancelled(false)
    end

    def attach_tickets
      pdf = TicketsWebPDF.new
      pdf.add_tickets @order.tickets
      attachments['tickets.pdf'] = pdf.render
    end

    def should_attach_tickets?
      !@order.cancelled? && (@order.paid || @order.charge_payment?)
    end
    helper_method :should_attach_tickets?

    def overview_url
      @overview_url ||= order_overview_url(@order.signed_info(authenticated: true))
    end
    helper_method :overview_url
  end
end
