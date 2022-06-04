# frozen_string_literal: true

module Ticketing
  module BoxOffice
    class TseTransactionCreateService
      attr_accessor :purchase

      CLIENT_ID_PREFIX = 'FasT-POS'
      PROCESS_TYPE = 'Kassenbeleg-V1'
      TRANSACTION_TYPE = 'Beleg'
      PAYMENT_CASH = 'Bar'
      PAYMENT_CASHLESS = 'Unbar'

      delegate :box_office, to: :purchase

      def initialize(purchase)
        @purchase = purchase
      end

      def execute
        connect_to_tse do |tse|
          register_client_id(tse)
          start_transaction(tse)
          finish_transaction(tse)
        end
      end

      private

      def register_client_id(tse)
        return if box_office.tse_client_id.present?

        tse.send_admin_command('RegisterClientID', ClientID: client_id)
        box_office.update(tse_client_id: client_id)
      end

      def start_transaction(tse)
        response = tse.send_time_admin_command('StartTransaction')

        @tse_device = Ticketing::TseDevice.find_or_create_by(serial_number: response[:SerialNumber]) do |d|
          res = tse.send_command('GetDeviceData', Name: 'PublicKey', Format: 'Base64')
          d.public_key = res[:Value]
        end

        @transaction_info = {
          client_id:,
          transaction_number: response[:TransactionNumber],
          start_time: Time.iso8601(response[:LogTime])
        }
      end

      def finish_transaction(tse)
        response = tse.send_time_admin_command(
          'FinishTransaction',
          TransactionNumber: @transaction_info[:transaction_number],
          Typ: PROCESS_TYPE, Data: process_data
        )

        @transaction_info[:process_type] = PROCESS_TYPE
        @transaction_info[:process_data] = process_data
        @transaction_info[:signature] = response[:Signature]
        @transaction_info[:signature_counter] = response[:SignatureCounter]
        @transaction_info[:end_time] = Time.iso8601(response[:LogTime])

        purchase.update(tse_device: @tse_device, tse_info: @transaction_info)
      end

      def process_data
        @process_data ||= "#{TRANSACTION_TYPE}^#{vat_totals}^#{payments}"
      end

      def vat_totals
        totals = purchase.items.group_by(&:vat_rate).transform_values { |v| v.sum(&:total) }
        [totals['standard'], totals['reduced'], 0, 0, totals['zero']].map { |t| format('%.2f', t || 0) }.join('_')
      end

      def payments
        payment_method = purchase.pay_method == 'cash' ? PAYMENT_CASH : PAYMENT_CASHLESS
        "#{format_total(purchase.total)}:#{payment_method}"
      end

      def format_total(total)
        format('%.2f', total || 0)
      end

      def client_id
        @client_id ||= box_office.tse_client_id || new_client_id
      end

      def new_client_id
        prefix = "#{CLIENT_ID_PREFIX}-"
        prefix << 'DEV-' unless Rails.env.production?
        "#{prefix}#{box_office.id}"
      end

      def connect_to_tse(&)
        Ticketing::Tse.connect(client_id, &)
      end
    end
  end
end
