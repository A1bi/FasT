require "prawn"

class TicketsPDF < Prawn::Document
  include ActionView::Helpers::NumberHelper
  
  TICKET_WIDTH = 595
  TICKET_HEIGHT = 280
  
  def initialize(retail = false)
    @retail = retail
    @tickets_drawn = 0
    
    margin = @retail ? [0] : [14, 0]
    @ticket_height = TICKET_HEIGHT - 1 - margin.first * 2 / 3
    page_size = @retail ? [TICKET_WIDTH, TICKET_HEIGHT] : "A4"

    super page_size: page_size, page_layout: :portrait, margin: margin, info: {
      Title:         t(:title),
      Author:        t(:author),
      Creator:       t(:creator),
      Producer:      t(:creator),
      CreationDate:  Time.now
    }
    
    fill_color "000000"
    stroke_color "000000"
    fonts = {}
    [["avenir", "Avenir"]].each do |font|
      fonts[font[1]] = { normal: Rails.root.join('app', 'assets', 'fonts', "#{font[0]}.ttf").to_s }
    end
    font_families.update(fonts)
    font "Avenir"
    @font_sizes = { normal: 17, small: 14, tiny: 11 }
    
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
    if (!@retail && cursor - @ticket_height < 0) || (@retail && @tickets_drawn > 0)
      start_new_page
      fill_background
    end
    
    ticket_margin = 12
    bounding_box([0, cursor - ticket_margin], width: TICKET_WIDTH, height: @ticket_height - ticket_margin * 2) do
      indent(10, 10) do
        text_indent = [35, 95]
        line_width = 0.5
        
        header_line_cursor = draw_header line_width
        bottom_info_height = 0
        float do
          bottom_info_height = draw_bottom_info_for_ticket ticket, text_indent.first, line_width
        end
        
        float do
          barcode_margin = 10
          move_up header_line_cursor
          bounding_box([bounds.width - text_indent.last, cursor - barcode_margin], width: text_indent.last, height: cursor - bottom_info_height - barcode_margin * 2) do
            indent(30, 20) do
              draw_barcode_for_ticket ticket
            end
          end
        end
        
        move_down 15
        indent(text_indent.first, text_indent.last) do
          bounding_box([0, cursor], width: bounds.width, height: bounds.height) do
            draw_event_info_for_date ticket.date
            draw_seat_info ticket.seat
            move_up 40
            draw_ticket_type_info ticket.type
          end
        end
      end
      
      move_down ticket_margin
    end
    
    if cursor > bounds.height / 3 && !@retail
      move_down ticket_margin
      draw_cut_line
    end
    
    @tickets_drawn = @tickets_drawn.next
  end

  def draw_barcode_for_ticket(ticket)
    rotate(-90, origin: [0, bounds.height]) do
      bounding_box([0, bounds.height + bounds.width], width: bounds.height, height: bounds.width) do
        BarcodePDF.draw_content("T#{ticket.number}M" + (@retail ? "0" : "1"), self)
      end
    end
  end
  
  def draw_header(line_width)
    line_cursor = 0
    font_size_name :small do
      header = t(:header)
      box_height = height_of header
      bounding_box([0, cursor], width: bounds.width, height: box_height) do
        text_width = 0
        character_spacing 1.2 do
          text_width = width_of header
          text header, align: :center, valign: :center
        end
    
        move_cursor_to box_height / 2
        draw_line(line_width) do
          padding = 10
          text_start = bounds.width / 2 - text_width / 2
          horizontal_line 0, text_start - padding
          horizontal_line text_start + text_width + padding, bounds.width
        end
        line_cursor = cursor
      end
    end
    line_cursor
  end

  def draw_event_info_for_date(date)
    event_image_path = Rails.root.join("app", "assets", "images", "theater", date.event.identifier, "ticket_header.svg")
    width = 370
    if @retail
      image event_image_path.sub_ext(".png"), width: width
    else
      svg File.read(event_image_path), at: [0, cursor], width: width
    end
    
    move_down 5
    font_size_name :normal do
      text (I18n.l date.date, format: t(:event_date_format))
    end
  
    font_size_name :small do
      pad_bottom(10) { text t(:opens, time: I18n.l(date.date - 1.hour, format: t(:opens_date_format))) }
      pad_bottom(30) { text t(:location) }
    end
  end

  def draw_seat_info(seat)
    texts = array_of_texts_with_translations %w(block seat), [seat.block.name, seat.number]
    draw_horizontal_array_of_texts texts, :normal, 8
  end

  def draw_ticket_type_info(type)    
    font_size_name :normal do
      text type.name, align: :right
      text (type.price.zero? ? "" : number_to_currency(type.price)), align: :right
    end
  end

  def draw_bottom_info_for_ticket(ticket, text_indent, line_width)
    padding = 15
    text_size = :tiny
    move_text_down = 4
    height = height_of(t(:website), size: @font_sizes[text_size]) + line_width + move_text_down
    
    bounding_box([0, height], width: bounds.width, height: height) do
      draw_line(line_width) do
        horizontal_line 0, bounds.right
      end
    
      move_down move_text_down
    
      indent(text_indent) do
        texts = array_of_texts_with_translations %w(ticket order), [ticket.number, ticket.order.number]
        texts.push t(:website)
        draw_horizontal_array_of_texts texts, text_size, padding
      end
    end
    
    height
  end
  
  def array_of_texts_with_translations(keys, values)
    values.each_with_index.map do |value, i|
      "#{t(keys[i])}: #{value}"
    end
  end

  def draw_horizontal_array_of_texts(texts, size, padding)
    font_size_name size do
      table([texts]) do |table|
        table.cells.padding = [0, padding]
        table.cells.valign = :bottom
        table.cells.border_width = 0.3
        table.column(0).padding_left = 0
        table.columns(0..-2).borders = [:right]
        table.column(-1).borders = []
      end
    end
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
    tmpCursor = cursor
    dash(10, space: 5, phase: 0)
    horizontal_line(0, bounds.width)
    stroke
    undash
    move_up(cursor - tmpCursor)
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
end