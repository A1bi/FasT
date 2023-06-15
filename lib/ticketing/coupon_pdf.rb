# frozen_string_literal: true

module Ticketing
  class CouponPdf < BasePdf
    FOLD_LINES_LENGTH = 50
    QUARTER_MARGIN = 20

    def initialize(coupon, theme: nil)
      @coupon = coupon
      @theme = theme

      super page_size: 'A4', page_layout: :landscape, margin: 0

      draw_coupon_details
      draw_front
      draw_back
      draw_folding_lines
    end

    private

    def draw_coupon_details
      quarter_bounding_box([half_page_width, half_page_height]) do
        text t(:title), align: :center, size: 25

        move_down 10
        font_size_name :small do
          text t(:value, value: number_to_currency(@coupon.initial_value)),
               align: :center, size: 17, inline_format: true
        end

        move_down 20
        font_size_name :small do
          text t(:code), align: :center
        end

        draw_coupon_code

        indent 80, 80 do
          font_size_name :normal do
            move_down 48
            text t(:recipient)
            draw_name_line

            move_down 40
            text t(:sender)
            draw_name_line
          end
        end
      end
    end

    def draw_front
      quarter_bounding_box([0, bounds.height], rotate: true, pad: false) do
        case @theme
        when :christmas
          draw_christmas_front
        else
          draw_generic_front
        end
      end
    end

    def draw_generic_front
      svg_image 'pdf/coupon/bow.svg',
                height: bounds.height * 0.4, position: :right

      pad_quarter do
        move_up 30
        text t(:title), size: 25, align: :center, styles: %i[bold]

        move_down 30
        svg_image 'pdf/logo_bw_l2.svg',
                  height: bounds.height * 0.3, position: :center
      end
    end

    def draw_christmas_front
      pad_quarter do
        move_down 5
        svg_image 'pdf/coupon/christmas_front.svg',
                  height: bounds.width * 0.6, position: :center
      end
    end

    def draw_back
      quarter_bounding_box([half_page_width, bounds.height], rotate: true) do
        move_down 30
        svg_image 'pdf/logo_bw_l2.svg',
                  height: bounds.height * 0.4, position: :center

        move_down 30
        indent 20, 20 do
          font_size_name :tiny do
            text t(:disclaimer), align: :center, inline_format: true
          end
        end
      end
    end

    def draw_coupon_code
      font_size = 16
      font 'Courier', size: font_size do
        move_down 3
        fill_color 'eeedf0'
        stroke_color 'b2b1b4'
        dash(10, space: 5, phase: 0)

        coupon_width = width_of @coupon.code
        box_padding = [10, 20]
        x = (bounds.width - coupon_width - box_padding[1] * 2) / 2
        width = coupon_width + box_padding[1] * 2
        height = font_size + box_padding[0] * 2
        fill_and_stroke { rectangle [x, cursor], width, height }

        move_down box_padding[0] + 3
        fill_color FG_COLOR
        text @coupon.code, align: :center

        undash
        fill_color FG_COLOR
        stroke_color FG_COLOR
      end
    end

    def draw_folding_lines
      stroke_color 'd1cfd2'
      dash(10, space: 5, phase: 0)

      stroke do
        # horizontal lines
        line [0, half_page_height],
             [FOLD_LINES_LENGTH, half_page_height]
        line [half_page_width - FOLD_LINES_LENGTH, half_page_height],
             [half_page_width + FOLD_LINES_LENGTH, half_page_height]
        line [bounds.width - FOLD_LINES_LENGTH, half_page_height],
             [bounds.width, half_page_height]

        # vertical lines
        line [half_page_width, bounds.height],
             [half_page_width, bounds.height - FOLD_LINES_LENGTH]
        line [half_page_width, half_page_height - FOLD_LINES_LENGTH],
             [half_page_width, half_page_height + FOLD_LINES_LENGTH]
        line [half_page_width, FOLD_LINES_LENGTH],
             [half_page_width, 0]
      end

      undash
    end

    def draw_name_line
      start = 50
      stroke { line [start, cursor], [bounds.width, cursor] }
    end

    def quarter_bounding_box(position, rotate: false, pad: true, &block)
      bounding_box(position, width: half_page_width,
                             height: half_page_height) do
        rotate(rotate ? 180 : 0,
               origin: [bounds.width / 2, bounds.height / 2]) do
          if pad
            pad_quarter(&block)
          else
            block.call
          end
        end
      end
    end

    def pad_quarter(&)
      pad QUARTER_MARGIN + 10 do
        indent(QUARTER_MARGIN, QUARTER_MARGIN, &)
      end
    end

    def half_page_width
      @half_page_width ||= bounds.width / 2
    end

    def half_page_height
      @half_page_height ||= bounds.height / 2
    end

    def i18n_scope
      :coupon_pdf
    end
  end
end
