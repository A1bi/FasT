class OrderMailer < BaseMailer
  def confirmation(order)
		@order = order
    
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
  
  def attach_tickets
    pdf = TicketsPDF.new
    pdf.add_order @order
    attachments['tickets.pdf'] = pdf.render
  end
end
