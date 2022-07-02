# frozen_string_literal: true

module Ticketing
  module BoxOffice
    class PurchasesController < BaseController
      skip_authorization only: :show

      def show
        purchase = Purchase.find_by!(receipt_token: params[:token])
        pdf = PurchaseReceiptPdf.new
        pdf.purchase = purchase
        send_data pdf.render, type: 'application/pdf', disposition: 'inline'
      end
    end
  end
end
