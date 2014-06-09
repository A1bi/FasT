class OrderMailer < BaseMailer
  @@passbook_mime_type = "application/vnd.apple.pkpass"
  
  default parts_order: ["multipart/alternative", "application/pdf", @@passbook_mime_type]
  
  helper Ticketing::TicketingHelper
  
  def confirmation(order)
		@order = order
    
    find_tickets
    attach_tickets if order.paid
		mail_to_customer
	end
  
  def payment_received(order)
    @order = order
    
    attach_tickets
    mail_to_customer
  end
  
  def overview(order)
    @order = order
    
    attach_tickets
    mail_to_customer
  end
  
  def pay_reminder(order)
    if order.is_a?(Ticketing::Web::Order) && order.transfer? && !order.paid
      @order = order
      
      find_tickets
      mail_to_customer
    end
  end
  
  def cancellation(order)
    if order.is_a?(Ticketing::Web::Order)
      @order = order
      
      mail_to_customer
    end
  end
  
  def resend_tickets(order)
    @order = order
    
    attach_tickets
    mail_to_customer
  end
  
  private
  
  def mail_to_customer
    mail to: @order.email if @order.email.present?
  end
  
  def find_tickets
    @tickets ||= @order.tickets.cancelled(false)
  end
  
  def attach_tickets
    pdf = TicketsPDF.new
    pdf.add_order @order
    attachments['tickets.pdf'] = pdf.render
    
    find_tickets
    @tickets.each do |ticket|
      attachments["passbook-#{ticket.number}.pkpass"] = {
        mime_type: @@passbook_mime_type,
        content: File.read(ticket.passbook_pass.path(true))
      }
    end
  end
end
