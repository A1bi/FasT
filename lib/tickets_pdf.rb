require "prawn"

class TicketsPDF < Prawn::Document
  include ActionView::Helpers::NumberHelper
  
  TICKET_WIDTH = 595
  TICKET_HEIGHT = 240
  
  def initialize
    super page_size: [TICKET_WIDTH, TICKET_HEIGHT], margin: [10, 40, 10, 10]
    
    fill_color "000000"
    stroke_color "000000"
    fonts = {}
    [["avenir", "Avenir"], ["snell_roundhand", "SnellRoundhand"]].each do |font|
      fonts[font[1]] = { normal: Rails.root.join('app', 'assets', 'fonts', "#{font[0]}.ttf").to_s }
    end
    font_families.update(fonts)
    font "Avenir"
    @font_sizes = { normal: 16, small: 13, tiny: 11 }
    
    @tickets_drawn = 0
  end
  
  def add_order(order)
    order.bunch.tickets.each do |ticket|
      draw_ticket ticket
    end
  end
  
  def add_ticket(ticket)
    draw_ticket ticket
  end
  
  private

  def draw_ticket(ticket)
    start_new_page if @tickets_drawn > 0
    
    barcodeWidth = 60
    bounding_box([0, bounds.height], width: barcodeWidth, height: bounds.height) do
      draw_barcode_for_ticket ticket
    end
    
    bounding_box([barcodeWidth, bounds.height], width: bounds.width - barcodeWidth) do
      move_down 4
      indent(30) do
        # draw_logo
        draw_event_info_for_date ticket.date
        draw_seat_info ticket.seat
        draw_ticket_type_info ticket.type
        draw_bottom_info_for_ticket ticket
      end
    end
    
    @tickets_drawn = @tickets_drawn + 1
  end

  def draw_barcode_for_ticket(ticket)
    margin = 10
    height = bounds.width - margin
    width = bounds.height
  
    rotate(-90, :origin => [0, bounds.height]) do
      bounding_box([0, bounds.height + height], width: width, height: height) do
        BarcodePDF.draw_content("T#{ticket.number}M1", self)
      end
    end
    
    draw_line(0.5) do
      vertical_line 0, bounds.height, at: height + margin - 0.5
    end
  end

  # def draw_logo
  #
  # end

  def draw_event_info_for_date(date)
    font("SnellRoundhand", size: 40) do
      pad_bottom(4) { text date.event.name }
    end
  
    font_size_name :normal do
      text (I18n.l date.date, format: "%A, den %d. %B um %H.%M Uhr")
    end
  
    font_size_name :small do
      pad_bottom(10) { text "Einlass ab 19.00 Uhr" }
      pad_bottom(30) { text "Historischer Ortskern, Kaisersesch" }
    end
  end

  def draw_seat_info(seat)
    texts = ["Block: #{seat.block.name}", "Reihe: #{seat.row}", "Sitz: #{seat.number}"]
    draw_horizontal_array_of_texts texts, :small, 8
  
    move_up 35
  end

  def draw_ticket_type_info(type)
    font_size_name :normal do
      text type.name, align: :right
      text number_to_currency(type.price), align: :right
    end

    move_down 23
  end

  def draw_bottom_info_for_ticket(ticket)
    draw_line(0.5) do
      horizontal_line 0, bounds.right
    end
    
    move_down 4
    
    indent(5) do
      texts = ["Ticket: #{ticket.number}", "Order: #{ticket.bunch.number}", "www.theater-kaisersesch.de"]
      draw_horizontal_array_of_texts texts, :tiny, 15
    end
  end

  def draw_horizontal_array_of_texts(texts, size, padding)
    font_size_name size do
      table([texts]) do |table|
        table.cells.padding = [0, padding]
        table.cells.border_width = 0.3
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
end