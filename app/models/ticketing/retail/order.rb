# frozen_string_literal: true

module Ticketing
  module Retail
    class Order < Ticketing::Order
      belongs_to :store

      before_create :transfer_cash_payment_from_store
      before_save :check_tickets
      after_save :check_printable
      after_commit :delete_printable, on: :destroy

      def printable_path(full = false)
        number_hash = Digest::SHA1.hexdigest(number.to_s)
        File.join(printable_dir_path(full), "tickets-#{number_hash}.pdf")
      end

      def cash_refund_in_store
        transfer_balance_to_store(:cash_refund_in_store)
      end

      private

      def transfer_cash_payment_from_store
        transfer_balance_to_store(:cash_in_store)
      end

      def transfer_balance_to_store(note_key)
        transfer_to_account(store, billing_account.balance, note_key)
      end

      def check_tickets
        tickets.each do |ticket|
          if ticket.changed?
            @update_printable = true
            break
          end
        end
      end

      def printable_dir_path(full = false)
        path = Rails.public_path if full
        File.join(path || '', '/system/tickets')
      end

      def update_printable
        FileUtils.mkdir_p(printable_dir_path(true))

        pdf = TicketsRetailPdf.new
        pdf.add_tickets tickets
        pdf.render_file(printable_path(true))
      end

      def check_printable
        return unless @update_printable

        update_printable
        @update_printable = false
      end

      def delete_printable
        FileUtils.rm(printable_path(true), force: true)
      end
    end
  end
end
