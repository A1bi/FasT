# frozen_string_literal: true

module Ticketing
  class OrderMailer < ApplicationMailer
    helper TicketingHelper
    helper Customers::OrdersHelper

    before_action :set_order
    before_action :prepare_tickets, :prepare_coupons
    before_action :prepare_billing, only: %i[confirmation pay_reminder cancellation]

    default to: -> { @order.email }

    def confirmation
      @pending_charge = @order.charge_payment? && @order.open_bank_transaction.present? &&
                        @order.open_bank_transaction.amount.positive?
      mail
    end

    def pay_reminder
      mail if @order.transfer_payment? && !@order.paid
    end

    def payment_received
      mail item_subject: true
    end

    def resend_items
      mail item_subject: true
    end

    def cancellation
      @reason = params[:reason]
      @bank_transaction = params[:bank_transaction]
      mail
    end

    def tickets_changed
      mail
    end

    private

    def set_order
      # prevent delivery and action processing if order is not a web order
      self.response_body = :null unless (@order = params[:order]).is_a? Web::Order
    end

    def mail(item_subject: false)
      if item_subject
        item_type = @tickets.any? ? :tickets : :coupons
        subject = t("ticketing.order_mailer.item_subjects.#{item_type}")
      end

      super subject:
    end

    def prepare_tickets
      @tickets = @order.tickets.valid
      return unless attach_tickets?

      pdf = TicketsWebPdf.new
      pdf.add_tickets @tickets
      attachments['Tickets.pdf'] = pdf.render
    end

    def attach_tickets?
      @tickets.any? && attach_items?
    end
    helper_method :attach_tickets?

    def prepare_coupons
      @coupons = @order.purchased_coupons
      return unless attach_coupons?

      @coupons.each_with_index do |coupon, i|
        pdf = CouponPdf.new(coupon)
        attachments["Gutschein #{i + 1}.pdf"] = pdf.render
      end

      attachments['Faltanleitung.pdf'] = Rails.root.join('app/assets/images/misc/coupon_instructions.pdf').read
    end

    def attach_coupons?
      @coupons.any? && attach_items?
    end
    helper_method :attach_coupons?

    def attach_items?
      @order.paid || @order.charge_payment?
    end

    def prepare_billing
      @billing_transactions = @order.billing_account.transactions.where.not(note_key: %i[order_created])
    end

    def overview_url
      @overview_url ||= order_overview_url(
        @order.signed_info(authenticated: true)
      )
    end
    helper_method :overview_url
  end
end
