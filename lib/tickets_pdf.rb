require "prawn"
require "prawn/table"
require "prawn/qrcode"

class TicketsPDF < Prawn::Document
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers

  TICKET_WIDTH = 595
  TICKET_HEIGHT = 280

  def initialize(margin = [14, 0], page_size = "A4", page_layout = :portrait)
    @tickets_drawn = 0
    @stamps = {}
    @ticket_height = TICKET_HEIGHT - 1 - margin.first * 2 / 3
    @ticket_margin = 12

    super page_size: page_size, page_layout: page_layout, margin: margin, info: {
      Title:         t(:title),
      Author:        t(:author),
      Creator:       t(:creator),
      CreationDate:  Time.now
    }

    fill_color "000000"
    stroke_color "000000"

    font_name = "OpenSans"
    fonts = {}
    [:normal, :bold].each do |style|
      (fonts[font_name] ||= {})[style] = Rails.root.join('app', 'assets', 'fonts', "#{font_name}-#{style}.ttf").to_s
    end
    font_families.update(fonts)
    font font_name
    @font_sizes = { normal: 15, small: 13, tiny: 11 }

    fill_background
  end

  def add_tickets(tickets)
    tickets.each do |ticket|
      draw_ticket ticket if !ticket.cancelled?
    end
  end

  def add_ticket(ticket)
    draw_ticket ticket
  end

  private

  def draw_ticket(ticket)
    bounding_box([0, cursor - @ticket_margin], width: TICKET_WIDTH, height: @ticket_height - @ticket_margin * 2) do
      indent(10, 10) do
        draw_header 0.5
        move_down 8

        bounding_box([0, cursor], width: bounds.width, height: cursor) do
          indent(20, 20) do
            indent(0, 140) do
              draw_event_info_for_date ticket.date
              draw_ticket_info ticket
            end

            move_cursor_to bounds.top
            indent(bounds.right - 135, 0) do
              draw_barcode_for_ticket(ticket)

              move_down 10

              draw_stamp(:logo, nil, true) do
                event_image_path = Rails.root.join('app', 'assets', 'images', 'logo_ticket.svg')
                svg File.read(event_image_path), width: bounds.width * 0.55, position: :center
              end
            end
          end
        end
      end

      move_down @ticket_margin
    end

    @tickets_drawn = @tickets_drawn.next
  end

  def draw_barcode_for_ticket(ticket)
    print_qr_code(barcode_content_for_ticket(ticket), extent: bounds.width.to_f)
  end

  def draw_header(line_width)
    font_size_name :small do
      header = t(:header)
      box_height = height_of header
      bounding_box([0, cursor], width: bounds.width, height: box_height) do
        text_width = 0
        character_spacing 1.2 do
          text_width = width_of header
          text header, align: :center
        end

        move_cursor_to box_height / 2
        draw_line(line_width) do
          padding = 10
          text_start = bounds.width / 2 - text_width / 2
          horizontal_line 0, text_start - padding
          horizontal_line text_start + text_width + padding, bounds.width
        end
      end
    end
  end

  def draw_event_info_for_date(date)
    create_stamp(:events, date.event) do
      bounding_box([0, cursor], width: bounds.width * 0.96, height: bounds.height * 0.38) do
        image_path = Rails.root.join("app/assets/images/theater/#{date.event.identifier}/ticket_header.svg")
        svg = Prawn::SVG::Interface.new(File.read(image_path), self, vposition: :center)

        svg.resize(width: bounds.width)
        if svg.sizing.output_height > bounds.height
          svg.resize(height: bounds.height)
        end

        svg.draw
      end
    end

    draw_stamp(:dates, date, true) do
      draw_stamp(:events, date.event, false)

      move_down 5

      draw_info_table([
        [t(:date), t(:begins), t(:opens)],
        [
          I18n.l(date.date, format: t(:date_format)),
          I18n.l(date.date, format: t(:time_format)),
          I18n.l(date.door_time, format: t(:time_format)),
        ]
      ])
    end
  end

  def draw_ticket_info(ticket)
    labels = [t(:location)]
    values = [ticket.event.location]

    if ticket.seat.nil?
      labels << ''
      values << t(:free_seating)

    else
      if ticket.block.entrance.present?
        labels << t(:entrance)
        values << ticket.block.entrance
      end

      labels << t(:block)
      values << ticket.block.name

      if ticket.seat.row.present?
        labels << t(:row)
        values << ticket.seat.row
      end

      labels << t(:seat)
      values << ticket.seat.number
    end

    draw_info_table([labels, values])

    if ticket.price.zero?
      labels = ['']
      values = [ticket.type.name]
    else
      labels = [ticket.type.name]
      values = [number_to_currency(ticket.price)]
    end

    labels << t(:ticket)
    values << ticket.number

    start = cursor
    table = draw_info_table([labels, values])

    float do
      move_up start - cursor - 12
      text_box t(:additional_info), size: 8, inline_format: true, at: [table.width, cursor]
    end
  end

  def draw_info_table(info, options = {}, &block)
    tiny_size = @font_sizes[:tiny]
    normal_size = @font_sizes[:normal]

    table(info, options) do
      cells.borders = []
      cells.padding = [2, 20, 0, 0]
      cells.size = normal_size
      cells.single_line = true
      cells.overflow = :shrink_to_fit

      even_rows = (0..info.count - 1).select(&:even?)
      row(even_rows).padding = [10, 20, 0, 0]
      row(even_rows).size = tiny_size

      odd_rows = (0..info.count - 1).select(&:odd?)
      row(odd_rows).font_style = :bold

      instance_eval(&block) if block_given?
    end
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

        @stamps[key][record] = {
          start: outer_start,
          height: start - cursor
        }
      end
    end

    @stamps[key][record][:height]
  end

  def draw_stamp(key, record, offset, &block)
    height = create_stamp(key, record, &block)
    stamp_at(stamp_name(key, record), [0, offset ? y - @stamps[key][record][:start] : 0])
    move_down height
  end

  def font_size_name(size)
    font_size @font_sizes[size] do
      yield if block_given?
    end
  end

  def draw_line(width)
    line_width = width
    stroke do
      yield
    end
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
      fill_color "ffffff"
      fill_rectangle [0, bounds.height], bounds.width, bounds.height
    end
  end

  def t(key, options = {})
    I18n.t(key, options.merge({ scope: :tickets_pdf }))
  end

  def barcode_content_for_ticket(ticket)
    medium = Ticketing::CheckIn.media[signed_info_medium]
    Settings.ticket_barcode_base_url + ticket.signed_info(medium: medium)
  end

  def signed_info_medium
    :unknown
  end
end
