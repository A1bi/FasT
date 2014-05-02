require "prawn"

class TicketsPDF < Prawn::Document
  include ActionView::Helpers::NumberHelper
  
  TICKET_WIDTH = 595
  TICKET_HEIGHT = 280
  
  def initialize(retail = false)
    @retail = retail
    
    page_size = @retail ? [TICKET_WIDTH, TICKET_HEIGHT] : "A4"

    super page_size: page_size, page_layout: @retail ? :landscape : :portrait, margin: [0, 0, 0, 0], info: {
      Title:         t(:title),
      Author:        t(:author),
      Creator:       t(:creator),
      Producer:      t(:creator),
      CreationDate:  Time.now
    }
    
    fill_color "000000"
    stroke_color "000000"
    fonts = {}
    [["avenir", "Avenir"], ["staccato", "Staccato"]].each do |font|
      fonts[font[1]] = { normal: Rails.root.join('app', 'assets', 'fonts', "#{font[0]}.ttf").to_s }
    end
    font_families.update(fonts)
    font "Avenir"
    @font_sizes = { normal: 17, small: 14, tiny: 11 }
  end
  
  def add_order(order)
    @tickets_drawn = 0
    order.tickets.each do |ticket|
      draw_ticket ticket
      @tickets_drawn = @tickets_drawn + 1
    end
  end
  
  def add_ticket(ticket)
    draw_ticket ticket
  end
  
  private

  def draw_ticket(ticket)
    if (!@retail && cursor - TICKET_HEIGHT < 0) || (@retail && @tickets_drawn > 0)
      start_new_page
    end
    
    draw_single = Proc.new do
      bounding_box([0, cursor], width: TICKET_WIDTH, height: TICKET_HEIGHT) do
        bounding_box([0, cursor - 10], width: bounds.width, height: bounds.height - 20) do
          indent(10, 30) do
            barcodeWidth = 70
            bounding_box([0, bounds.height], width: barcodeWidth, height: bounds.height) do
              draw_barcode_for_ticket ticket
            end

            bounding_box([barcodeWidth, bounds.height], width: bounds.width - barcodeWidth, height: bounds.height) do
              move_down 4
              indent(30) do
                draw_event_info_for_date ticket.date
                draw_seat_info ticket.seat
                draw_ticket_type_info ticket.type
                draw_bottom_info_for_ticket ticket
              end
            end
          end
        end
      end
    end
    
    if @retail
      rotate(-90, :origin => [140, 455], &draw_single)
    else
      draw_single.call
    end
    
    if cursor > bounds.height / 3 && !@retail
      draw_cut_line
    end
  end

  def draw_barcode_for_ticket(ticket)
    margin = 10
    height = bounds.width - margin
    width = bounds.height
  
    rotate(-90, :origin => [0, bounds.height]) do
      bounding_box([0, bounds.height + height], width: width, height: height) do
        BarcodePDF.draw_content("T#{ticket.number}M" + (@retail ? "0" : "1"), self)
      end
    end
    
    draw_line(0.5) do
      vertical_line 0, bounds.height, at: height + margin - 0.5
    end
  end

  def draw_event_info_for_date(date)
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
        draw_line(0.5) do
          padding = 10
          text_start = bounds.width / 2 - text_width / 2
          horizontal_line 0, text_start - padding
          horizontal_line text_start + text_width + padding, bounds.width
        end
      end
    end
    
    font("Staccato", size: 40) do
      pad(5) { text date.event.name }
    end
  
    font_size_name :normal do
      text (I18n.l date.date, format: t(:event_date_format))
    end
  
    font_size_name :small do
      pad_bottom(10) { text t(:opens) }
      pad_bottom(35) { text t(:location) }
    end
  end

  def draw_seat_info(seat)
    texts = array_of_texts_with_translations %w(block seat), [seat.block.name, seat.number]
    draw_horizontal_array_of_texts texts, :small, 8
  end

  def draw_ticket_type_info(type)
    move_up 45
    
    indent(0, 20) do
      font_size_name :normal do
        text type.name, align: :right
        text (type.price.zero? ? "" : number_to_currency(type.price)), align: :right
      end
    end
  end

  def draw_bottom_info_for_ticket(ticket)
    bounding_box([0, 20], width: bounds.width, height: 20) do
      draw_line(0.5) do
        horizontal_line 0, bounds.right
      end
    
      move_down 4
    
      indent(5) do
        texts = array_of_texts_with_translations %w(ticket order), [ticket.number, ticket.order.number]
        texts.push t(:website)
        draw_horizontal_array_of_texts texts, :tiny, 15
      end
    end
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
  
  def t(key)
    I18n.t(key, :scope => :tickets_pdf)
  end
end