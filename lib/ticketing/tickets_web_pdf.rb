# frozen_string_literal: true

module Ticketing
  class TicketsWebPdf < TicketsPdf
    private

    def draw_ticket(ticket)
      if (cursor - @ticket_height).negative?
        start_new_page
        fill_background
      end

      super

      return if cursor < bounds.height / 3

      move_down TICKET_Y_MARGIN
      draw_cut_line
    end

    def signed_info_medium
      :web
    end

    def includes_links?
      true
    end
  end
end
