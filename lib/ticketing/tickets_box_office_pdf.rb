# frozen_string_literal: true

module Ticketing
  class TicketsBoxOfficePdf < TicketsPdf
    def initialize
      super(margin: [0])
    end

    private

    def draw_ticket(ticket)
      bounding_box([0, bounds.height], width: TICKET_WIDTH, height: TICKET_HEIGHT) do
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
end
