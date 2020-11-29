# frozen_string_literal: true

module Ticketing
  class CouponPdf < BasePdf
    FOLD_LINES_LENGTH = 50
    QUARTER_MARGIN = 20

    def initialize(coupon)
      @coupon = coupon

      super page_size: 'A4', page_layout: :landscape, margin: 0

      draw_coupon_details
      draw_front
      draw_back
      draw_cut_lines
    end

    private

    def draw_coupon_details
      quarter_bounding_box([half_page_width, half_page_height], false) do
        text t(:title), align: :center, size: 25

        move_down 10
        font_size_name :small do
          text t(:amount, amount: number_to_currency(@coupon.amount)),
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
            text 'für:'
            draw_name_line

            move_down 40
            text 'von:'
            draw_name_line
          end
        end
      end
    end

    def draw_front
      quarter_bounding_box([0, bounds.height], true) do
        move_down 5
        event_image_path = images_path.join('pdf/coupon_front.svg')
        svg File.read(event_image_path),
            height: bounds.width * 0.6, position: :center
      end
    end

    def draw_back
      quarter_bounding_box([half_page_width, bounds.height], true) do
        move_down 30
        event_image_path = images_path.join('pdf/logo.svg')
        svg File.read(event_image_path),
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

    def draw_cut_lines
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

    def quarter_bounding_box(position, rotate, &block)
      bounding_box(position, width: half_page_width,
                             height: half_page_height) do
        rotate(rotate ? 180 : 0,
               origin: [bounds.width / 2, bounds.height / 2]) do
          pad QUARTER_MARGIN + 10 do
            indent QUARTER_MARGIN, QUARTER_MARGIN, &block
          end
        end
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
