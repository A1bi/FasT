class TicketsWebPDF < TicketsPDF
  private

  def draw_ticket(ticket)
    if cursor - @ticket_height < 0
      start_new_page
      fill_background
    end

    super

    if cursor > bounds.height / 3
      move_down @ticket_margin
      draw_cut_line
    end
  end

  def signed_info_medium
    1
  end
end
