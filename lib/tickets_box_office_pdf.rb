class TicketsBoxOfficePDF < TicketsPDF  
  def initialize
    margin = [0]
    page_size = "A4"
    
    super(margin, page_size, :landscape)
  end
  
  private

  def draw_ticket(ticket)    
    bounding_box([bounds.width - TICKET_WIDTH, bounds.height - (bounds.height - TICKET_HEIGHT) / 2], width: TICKET_WIDTH, height: TICKET_HEIGHT) do
    
      if @tickets_drawn > 0
        start_new_page
        fill_background
      end
      
      super
      
    end
  end
  
  def signed_ticket_info_extension
    2
  end
end