# frozen_string_literal: true

module Ticketing
  class RefundMailer < ApplicationMailer
    helper TicketingHelper

    before_action { @order = params[:order] }

    layout 'ticketing/order_mailer', only: :customer

    def customer
      mail to: @order.email
    end

    def internal
      attachments['refund.xml'] = transfer.to_xml
      mail to: 'albrecht@oster.online'
    end

    private

    def transfer
      transfer = SEPA::CreditTransfer.new(creditor_info)
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
      %i[name iban].each_with_object({}) do |key, info|
        info[key] = I18n.t(key, scope: 'ticketing.payments.submissions')
      end
    end
  end
end
