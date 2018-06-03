class TicketsRetailPDF < TicketsPDF
  def initialize
    margin = [0]
    page_size = [TICKET_WIDTH, TICKET_HEIGHT]

    super(margin, page_size)
  end

  private

  def draw_ticket(ticket)
    if @tickets_drawn > 0
      start_new_page
      fill_background
    end

    super
  end

  def signed_info_medium
    2
  end
end
