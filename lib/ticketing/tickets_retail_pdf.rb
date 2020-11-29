# frozen_string_literal: true

module Ticketing
  class TicketsRetailPdf < TicketsPdf
    def initialize
      super(margin: [0], page_size: [TICKET_WIDTH, TICKET_HEIGHT])
    end

    private

    def draw_ticket(ticket)
      if @tickets_drawn.positive?
        start_new_page
        fill_background
      end

      super
    end

    def signed_info_medium
      :retail
    end
  end
end
