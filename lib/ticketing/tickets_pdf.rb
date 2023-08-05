# frozen_string_literal: true

module Ticketing
  class TicketsPdf < BasePdf
    include ApplicationHelper

    TICKET_WIDTH = 595
    TICKET_HEIGHT = 280
    TICKET_X_MARGIN = 25
    TICKET_Y_MARGIN = 12

    def initialize(margin: [14, 0], page_size: 'A4', page_layout: :portrait)
      @tickets_drawn = 0
      @ticket_height = TICKET_HEIGHT - 1 - margin.first * 2 / 3

      super
    end

    def add_tickets(tickets)
      tickets.reject(&:cancelled?).each { |ticket| draw_ticket ticket }
    end

    private

    def draw_ticket(ticket)
      y = cursor - TICKET_Y_MARGIN
      top_padding = 15
      height = @ticket_height - TICKET_Y_MARGIN * 2 - top_padding
      bounding_box([TICKET_X_MARGIN, y - top_padding], width: TICKET_WIDTH - TICKET_X_MARGIN * 2, height:) do
        indent(0, 140) do
          draw_event_info_for_date ticket.date
          draw_location_info ticket
          draw_ticket_info ticket
        end

        bounding_box([bounds.right - 135, bounds.top], width: 135, height: bounds.height - cursor - 2) do
          draw_barcode_for_ticket(ticket)
          draw_logo
        end

        move_down TICKET_Y_MARGIN
      end

      @tickets_drawn += 1
    end

    def draw_barcode_for_ticket(ticket)
      link = barcode_content_for_ticket(ticket)
      print_qr_code(link, extent: bounds.width.to_f, foreground_color: FG_COLOR)

      return unless includes_links?

      link = barcode_link_for_ticket(ticket, authenticated: true)
      link_annotate(link, [0, -bounds.width, 0, 0])
    end

    def create_event_info_stamp(event)
      create_stamp(:events, event) do
        width = bounds.width * 0.9
        height = bounds.height * 0.3

        bounding_box([0, cursor], width:, height:) do
          draw_event_logo(event)
        end
      end
    end

    def draw_event_info_for_date(date)
      create_event_info_stamp date.event

      draw_stamp(:dates, date, true) do
        draw_stamp(:events, date.event, false)

        move_down 15

        draw_info_table(
          %i[date begins opens],
          [
            I18n.l(date.date, format: t(:date_format)),
            I18n.l(date.date, format: t(:time_format)),
            I18n.l(date.admission_time, format: t(:time_format))
          ]
        )
      end
    end

    def draw_ticket_info(ticket)
      if ticket.price.zero?
        labels = ['']
        values = [ticket.type.name]
      else
        labels = [ticket.type.name]
        values = [number_to_currency(ticket.price)]
      end

      labels << :ticket
      values << ticket.number

      start = cursor
      table = draw_info_table(labels, values)

      float do
        move_up start - cursor - 12
        text_box t(:additional_info), size: FONT_SIZES[:tiny],
                                      inline_format: true,
                                      at: [table.width, cursor]
      end
    end

    def draw_location_info(ticket)
      labels = []
      values = []
      additional = []

      labels << :location
      values << ticket.event.location.name
      additional << ticket.event.location.address

      if ticket.seat.present?
        labels += %i[entrance block row seat]
        values += [ticket.block.entrance, ticket.block.name, ticket.seat.row,
                   ticket.seat.number]
      elsif ticket.event.covid19?
        labels << :covid19_seat
        values << t(:covid19_seating)
      else
        labels << ''
        values << t(:free_seating)
      end

      draw_info_table(labels, values, additional)
    end

    def draw_info_table(labels, values, additional = [])
      small_size = FONT_SIZES[:small]
      normal_size = FONT_SIZES[:normal]

      values.each.with_index do |val, i|
        if val.blank?
          labels[i] = nil
        elsif labels[i].is_a? Symbol
          labels[i] = t(labels[i])
        end
      end

      table([labels.compact, values.compact, additional]) do
        cells.borders = []
        cells.padding = [2, 20, 0, 0]
        cells.size = normal_size
        cells.single_line = true
        cells.overflow = :shrink_to_fit

        row(0).padding = [10, 20, 0, 0]
        row(0).size = small_size
        row(1).font_style = :bold
        row(2).size = 9
      end
    end

    def draw_logo
      draw_stamp(:logo, nil, true) do
        svg_image 'pdf/logo_bw_l3.svg', width: bounds.width * 0.8, position: :right, vposition: :bottom
      end
    end

    def draw_event_logo(event)
      if (path = event_logo_path(event)).nil?
        return font 'Lora', style: :bold_italic do
          text_box event.name, size: 35, valign: :center, overflow: :shrink_to_fit, single_line: true
        end
      end

      image = File.read(images_path.join(path))
      svg = Prawn::SVG::Interface.new(image, self, vposition: :center)
      svg.resize(width: bounds.width)
      svg.resize(height: bounds.height) if svg.sizing.output_height > bounds.height
      svg.draw
    end

    def link_annotate(url, offsets)
      link_annotation(
        [
          bounds.absolute_left + offsets[0],
          bounds.absolute_top + offsets[1],
          bounds.absolute_right + offsets[2],
          bounds.absolute_top + offsets[3]
        ],
        A: {
          Type: :Action, S: :URI,
          URI: PDF::Core::LiteralString.new(url)
        }
      )
    end

    def draw_cut_line
      start = cursor
      dash(10, space: 5, phase: 0)
      horizontal_line(0, bounds.width)
      stroke
      undash
      move_up(cursor - start)
    end

    def barcode_link_for_ticket(ticket, medium: nil, authenticated: false)
      Settings.ticket_barcode_base_url +
        ticket.signed_info(medium:, authenticated:)
    end

    def barcode_content_for_ticket(ticket)
      medium = Ticketing::CheckIn.media[signed_info_medium]
      barcode_link_for_ticket(ticket, medium:)
    end

    def signed_info_medium
      :unknown
    end

    def includes_links?
      false
    end

    def i18n_scope
      :tickets_pdf
    end
  end
end
