class OrderMailer < ActionMailer::Base
  default from: I18n.t("action_mailer.defaults.from")
	
	def confirmation(order)
		@order = order
    
    if order.pay_method == "charge"
      attach_tickets
    end
		
		mail_to_customer
	end
  
  def payment_received(order)
    @order = order
    
    attach_tickets
    mail_to_customer
  end
  
  private
  
  def mail_to_customer
    mail to: (Rails.env.development?) ? "albo@a0s.de" : @order.email
  end
  
  def attach_tickets
    attachments['tickets.pdf'] = File.read(@order.bunch.printable_path(true))
  end
end
