# frozen_string_literal: true

module Ticketing
  class RefundMailer < ApplicationMailer
    helper TicketingHelper

    before_action { @order = params[:order] }

    default to: -> { @order.email }
    layout 'ticketing/order_mailer', except: :internal

    def customer
      mail
    end

    def notification
      mail
    end

    def internal
      return unless @order.billing_account.credit?

      attachments['refund.xml'] = transfer.to_xml
      mail to: 'albrecht@oster.online'
    end

    private

    def transfer
      transfer = SEPA::CreditTransfer.new(creditor_info)
      transfer.message_identification = "FasT/#{@order.id}/#{SecureRandom.hex(8)}"
      transfer.add_transaction(
        name: params[:name],
        iban: params[:iban],
        amount: @order.balance,
        remittance_information:
          "Erstattung zu Ihrer Bestellung mit der Nummer #{@order.number}"
      )
      transfer
    end

    def creditor_info
      %i[name iban].index_with do |key|
        I18n.t(key, scope: 'ticketing.payments.submissions')
      end
    end

    def overview_url
      @overview_url ||= order_overview_url(
        @order.signed_info(authenticated: true)
      )
    end
    helper_method :overview_url
  end
end
