# frozen_string_literal: true

require 'prawn/measurement_extensions'

module Ticketing
  module BoxOffice
    class PurchaseReceiptPdf < BasePdf
      attr_reader :purchase

      VAT_RATES = {
        standard: { letter: 'A', rate: 19 },
        reduced: { letter: 'B', rate: 7 },
        zero: { letter: 'C', rate: 0 }
      }.freeze

      def initialize(purchase)
        @purchase = purchase

        super(margin: 5.mm, page_size: [80.mm, 200.mm], page_layout: :portrait)

        font_size 8
        stroke_color '000000'
        font 'Courier'

        draw_header
        draw_items_table
      end

      private

      def draw_header
        svg_image 'pdf/logo_bw.svg', width: bounds.width * 0.40, position: :center
        move_down 10

        text t(:header), align: :center
        move_down 20
      end

      def draw_items_table
        rows = [[t(:article), 'EUR', nil]]

        rows += purchase.items.map do |item|
          first_column = [item_description(item), number_description(item)].compact.join("\n")
          [first_column, format_amount(item.total), VAT_RATES[item.vat_rate.to_sym][:letter]]
        end

        rows << [t(:total), format_amount(purchase.total), nil]

        table(rows, width: bounds.width) do
          cells.borders = []
          cells.padding = [2, 3]
          columns(0).width = 150
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

        "#{spaces(2)}#{item.number} x #{format_amount(item.purchasable.price)}"
      end

      def format_amount(amount)
        number_to_currency(amount, format: '%n')
      end

      def format_percentage(percentage)
        number_to_percentage(percentage, precision: 2, format: '%n %', separator: ',')
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
