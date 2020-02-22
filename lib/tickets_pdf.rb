# frozen_string_literal: true

class TicketsPdf < Prawn::Document
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers

  TICKET_WIDTH = 595
  TICKET_HEIGHT = 280
  TICKET_MARGIN = 12

  FONT_NAME = 'OpenSans'
  FONT_STYLES = %i[normal bold].freeze
  FONT_SIZES = { normal: 14, small: 11, tiny: 8 }.freeze

  FG_COLOR = '000000'
  BG_COLOR = 'ffffff'

  def initialize(margin: [14, 0], page_size: 'A4', page_layout: :portrait)
    @tickets_drawn = 0
    @stamps = {}
    @ticket_height = TICKET_HEIGHT - 1 - margin.first * 2 / 3

    super page_size: page_size, page_layout: page_layout, margin: margin,
          info: {
            Title: t(:title),
            Author: t(:author),
            Creator: t(:creator),
            CreationDate: Time.current
          }

    fill_color FG_COLOR
    stroke_color FG_COLOR

    paths = FONT_STYLES.each_with_object({}) do |style, obj|
      obj[style] = assets_path.join('fonts', "#{FONT_NAME}-#{style}.ttf").to_s
    end
    font_families.update(FONT_NAME => paths)
    font FONT_NAME

    fill_background
  end

  def add_tickets(tickets)
    tickets.reject(&:cancelled?).each { |ticket| draw_ticket ticket }
  end

  def add_ticket(ticket)
    draw_ticket ticket unless ticket.cancelled?
  end

  private

  def draw_ticket(ticket)
    y = cursor - TICKET_MARGIN
    height = @ticket_height - TICKET_MARGIN * 2
    bounding_box([0, y], width: TICKET_WIDTH, height: height) do
      indent(25, 25) do
        draw_header
        move_down 15

        bounding_box([0, cursor], width: bounds.width, height: cursor) do
          indent(0, 140) do
            draw_event_info_for_date ticket.date
            draw_location_info ticket
            draw_ticket_info ticket
          end

          move_cursor_to bounds.top
          indent(bounds.right - 135, 0) do
            draw_barcode_for_ticket(ticket)
            move_down 10
            draw_logo
          end
        end
      end

      move_down TICKET_MARGIN
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

  def draw_header
    font_size_name :small do
      header = t(:header)
      box_height = height_of header
      bounding_box([0, cursor], width: bounds.width, height: box_height) do
        text_width = 0
        character_spacing 2 do
          text_width = width_of header
          text header, align: :center
        end

        move_cursor_to box_height / 2
        line_width 0.5
        stroke do
          padding = 10
          text_start = bounds.width / 2 - text_width / 2
          horizontal_line 0, text_start - padding
          horizontal_line text_start + text_width + padding, bounds.width
        end
      end
    end
  end

  def create_event_info_stamp(event)
    create_stamp(:events, event) do
      width = bounds.width * 0.96
      height = bounds.height * (event.subtitle.present? ? 0.28 : 0.35)

      if event.subtitle.present?
        font_size_name :small do
          text event.subtitle
        end
        move_down 10
      end

      bounding_box([0, cursor], width: width, height: height) do
        image = File.read(images_path.join('theater', event.assets_identifier,
                                           'ticket_header.svg'))
        svg = Prawn::SVG::Interface.new(image, self, vposition: :center)

        svg.resize(width: bounds.width)
        if svg.sizing.output_height > bounds.height
          svg.resize(height: bounds.height)
        end

        svg.draw
      end
    end
  end

  def draw_event_info_for_date(date)
    create_event_info_stamp date.event

    draw_stamp(:dates, date, true) do
      draw_stamp(:events, date.event, false)

      move_down 5

      draw_info_table(
        %i[date begins opens],
        [
          I18n.l(date.date, format: t(:date_format)),
          I18n.l(date.date, format: t(:time_format)),
          I18n.l(date.door_time, format: t(:time_format))
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

    if ticket.event.location.present?
      labels << :location
      ticket.event.location.split("\n").each_with_index do |part, i|
        if i.zero?
          values << part
        else
          additional << part
        end
      end
    end

    if ticket.seat.nil?
      labels << ''
      values << t(:free_seating)
    else
      labels += %i[entrance block row seat]
      values += [ticket.block.entrance, ticket.block.name, ticket.seat.row,
                 ticket.seat.number]
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
      width_scale = 0.55

      event_image_path = images_path.join('logo_ticket.svg')
      svg File.read(event_image_path),
          width: bounds.width * width_scale, position: :center

      next unless includes_links?

      margin = bounds.width * (0.5 - width_scale / 2)
      link_annotate(root_url, [margin, -bounds.height + cursor,
                               -margin, -bounds.height + cursor])
    end
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

  def stamp_name(key, record)
    "#{key}_#{record ? record.id : 'default'}"
  end

  def create_stamp(key, record, &block)
    if (@stamps[key] ||= {})[record].nil?
      outer_start = y
      float do
        start = cursor
        super(stamp_name(key, record), &block)
        height = start - cursor

        @stamps[key][record] = [outer_start, height]
      end
    end

    @stamps[key][record]
  end

  def draw_stamp(key, record, offset, &block)
    start, height = create_stamp(key, record, &block)
    stamp_at(stamp_name(key, record), [0, offset ? y - start : 0])
    move_down height
  end

  def font_size_name(size)
    font_size(FONT_SIZES[size]) { yield if block_given? }
  end

  def draw_cut_line
    start = cursor
    dash(10, space: 5, phase: 0)
    horizontal_line(0, bounds.width)
    stroke
    undash
    move_up(cursor - start)
  end

  def fill_background
    save_graphics_state do
      canvas do
        fill_color BG_COLOR
        fill_rectangle [0, bounds.height], bounds.width, bounds.height
      end
    end
  end

  def t(key, options = {})
    I18n.t(key, options.merge(scope: :tickets_pdf))
  end

  def assets_path
    Rails.root.join('app/assets')
  end

  def images_path
    assets_path.join('images')
  end

  def barcode_link_for_ticket(ticket, medium: nil, authenticated: false)
    Settings.ticket_barcode_base_url +
      ticket.signed_info(medium: medium, authenticated: authenticated)
  end

  def barcode_content_for_ticket(ticket)
    medium = Ticketing::CheckIn.media[signed_info_medium]
    barcode_link_for_ticket(ticket, medium: medium)
  end

  def signed_info_medium
    :unknown
  end

  def includes_links?
    false
  end
end
