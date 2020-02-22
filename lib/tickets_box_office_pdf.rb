# frozen_string_literal: true

class TicketsBoxOfficePdf < TicketsPdf
  def initialize
    super(margin: [0], page_size: 'A4', page_layout: :landscape)
  end

  private

  def draw_ticket(ticket)
    x = bounds.width - TICKET_WIDTH
    y = bounds.height - (bounds.height - TICKET_HEIGHT) / 2

    bounding_box([x, y], width: TICKET_WIDTH, height: TICKET_HEIGHT) do
      if @tickets_drawn.positive?
        start_new_page
        fill_background
      end

      super
    end
  end

  def signed_info_medium
    :box_office
  end
end
