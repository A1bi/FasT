# frozen_string_literal: true

require 'prawn/measurement_extensions'

module Ticketing
  module BoxOffice
    class PurchaseReceiptPdf < BasePdf
      attr_reader :purchase

      VAT_RATE_LETTERS = {
        standard: 'A',
        reduced: 'B',
        zero: 'C'
      }.freeze

      def initialize
        super(margin: 5.mm, page_size: [80.mm, 1.m], page_layout: :portrait)

        font_size 8
        stroke_color '000000'
      end

      def purchase=(purchase)
        @purchase = purchase

        draw_header
        draw_items_table
        draw_vat_table
        draw_footer
        draw_tse_info
        adjust_page_height
      end

      private

      def draw_header
        svg_image 'pdf/logo_bw_l2.svg', width: bounds.width * 0.40, position: :center
        move_down 10

        text t(:header), align: :center, inline_format: true
        move_down 20
      end

      def draw_items_table
        rows = [[t(:article), 'EUR', nil]]

        rows += purchase.items.map do |item|
          first_column = [item_description(item), number_description(item)].compact.join("\n")
          [first_column, format_amount(item.total), VAT_RATE_LETTERS[item.vat_rate.to_sym]]
        end

        rows << [t(:total), format_amount(purchase.total), nil]

        width = bounds.width
        table(rows, width: bounds.width) do
          cells.borders = []
          cells.padding = [2, 3]
          columns(0).width = width * 0.8
          columns(1..2).align = :right
          row(0).borders = [:bottom]
          row(0).border_width = 0.5
          row(-2).padding = [2, 3, 10, 3]
          row(-1).borders = [:top]
          row(-1).border_width = 1
          row(-1).font_style = :bold
        end

        move_down 10
      end

      def item_description(item)
        case item.purchasable
        when Product
          item.purchasable.name
        when Ticket
          "#{t(:ticket)} #{item.purchasable.type.name}\n#{spaces(2)}##{item.purchasable.number}"
        when OrderPayment
          "#{t(:order_payment)}\n#{spaces(2)}##{item.purchasable.order.number}"
        end
      end

      def number_description(item)
        return unless item.number > 1

        "#{spaces(2)}#{item.number} × #{format_amount(item.purchasable.price)}"
      end

      def draw_vat_table
        rows = [[t(:vat_rate), t(:net), t(:vat), t(:gross)]]

        rows += purchase.totals_by_vat_rate.each_with_object([]) do |(rate_id, totals), r|
          next if totals[:gross].zero?

          description = if rate_id == :total
                          t(:total)
                        else
                          "#{VAT_RATE_LETTERS[rate_id]} = #{format_percentage(Purchase::VAT_RATES[rate_id])}"
                        end
          r << [
            description,
            *totals.values_at(:net, :vat, :gross).map { |amount| format_amount(amount) }
          ]
        end.compact

        table(rows, width: bounds.width) do
          cells.size = 7
          cells.borders = []
          cells.padding = [1, 3]
          columns(1..3).align = :right
          row(-1).font_style = :bold
        end

        move_down 20
      end

      def draw_footer
        rows = [
          [t(:date), t(:time), t(:box_office), t(:transaction)],
          [
            l(purchase.created_at, format: '%d.%m.%Y'),
            l(purchase.created_at, format: '%H:%M:%S'),
            purchase.box_office.id,
            purchase.id
          ]
        ]

        table(rows, width: bounds.width) do
          cells.borders = []
          cells.padding = [1, 3]
          columns(2..3).align = :right
        end
        move_down 20

        text t(:footer), align: :center
      end

      def draw_tse_info
        return if purchase.tse_info.nil?

        move_down 20
        text t(:tse_info), size: 7, align: :center
        print_qr_code tse_data, stroke: false, align: :center
      end

      def adjust_page_height
        page.dictionary.data[:MediaBox] = [
          0, y - page.margins[:bottom],
          bounds.width + page.margins[:left] + page.margins[:right],
          bounds.height + page.margins[:top] + page.margins[:bottom]
        ]
      end

      def tse_data
        [
          'V0', purchase.box_office.tse_client_id,
          *purchase.tse_info.values_at('process_type', 'process_data', 'transaction_number', 'signature_counter'),
          *purchase.tse_info.values_at('start_time', 'end_time').map { |time| format_tse_time(time) },
          'ecdsa-plain-SHA384', 'unixTime',
          purchase.tse_info['signature'], purchase.tse_device.public_key
        ].join(';')
      end

      def format_amount(amount)
        number_to_currency(amount, format: '%n')
      end

      def format_percentage(percentage)
        number_to_percentage(percentage, precision: 2, format: '%n %', separator: ',')
      end

      def format_tse_time(time)
        DateTime.parse(time).utc.iso8601(3)
      end

      def spaces(number)
        Prawn::Text::NBSP * number
      end

      def i18n_scope
        %i[box_office purchase_receipt]
      end
    end
  end
end
