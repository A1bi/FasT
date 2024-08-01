# frozen_string_literal: true

module Ticketing
  module Retail
    class Order < Ticketing::Order
      belongs_to :store

      validate :sale_enabled_for_store, on: :create

      def printable
        pdf = TicketsRetailPdf.new
        pdf.add_tickets tickets
        pdf
      end

      def anonymizable?
        false
      end

      private

      def sale_enabled_for_store
        errors.add :store, 'has sale disabled' unless store&.sale_enabled?
      end
    end
  end
end
