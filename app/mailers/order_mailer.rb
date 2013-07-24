class OrderMailer < BaseMailer
  def confirmation(order)
		@order = order
    
    attach_tickets if order.bunch.paid
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
    if order.is_a?(Ticketing::Web::Order) && order.pay_method == "transfer" && !order.bunch.paid
      @order = order
      
      mail_to_customer
    end
  end
  
  private
  
  def mail_to_customer
    mail to: @order.email
  end
  
  def attach_tickets
    pdf = TicketsPDF.new
    pdf.add_bunch @order.bunch
    attachments['tickets.pdf'] = pdf.render
  end
end
