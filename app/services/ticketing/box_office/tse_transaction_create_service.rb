# frozen_string_literal: true

module Ticketing
  module BoxOffice
    class TseTransactionCreateService
      attr_accessor :purchase

      CLIENT_ID_PREFIX = 'FasT-POS'

      delegate :box_office, to: :purchase

      def initialize(purchase)
        @purchase = purchase
      end

      def execute
        connect_to_tse do |tse|
          register_client_id(tse)
        end
      end

      private

      def register_client_id(tse)
        return if box_office.tse_client_id.present?

        tse.send_admin_command('RegisterClientID', ClientID: client_id)
        box_office.update(tse_client_id: client_id)
      end

      def client_id
        box_office.tse_client_id || new_client_id
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
