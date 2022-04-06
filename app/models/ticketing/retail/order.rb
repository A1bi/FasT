# frozen_string_literal: true

module Ticketing
  module Retail
    class Order < Ticketing::Order
      belongs_to :store

      before_save :check_tickets
      after_save :check_printable
      after_commit :delete_printable, on: :destroy

      def printable_path(absolute: false)
        number_hash = Digest::SHA1.hexdigest(number.to_s)
        "#{printable_dir_path(absolute:)}/tickets-#{number_hash}.pdf"
      end

      private

      def check_tickets
        tickets.each do |ticket|
          if ticket.changed?
            @update_printable = true
            break
          end
        end
      end

      def printable_dir_path(absolute: false)
        path = Rails.public_path if absolute
        "#{path}/system/tickets"
      end

      def update_printable
        FileUtils.mkdir_p(printable_dir_path(absolute: true))

        pdf = TicketsRetailPdf.new
        pdf.add_tickets tickets
        pdf.render_file(printable_path(absolute: true))
      end

      def check_printable
        return unless @update_printable

        update_printable
        @update_printable = false
      end

      def delete_printable
        FileUtils.rm(printable_path(absolute: true), force: true)
      end
    end
  end
end
