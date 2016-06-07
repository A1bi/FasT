class OrderMailer < BaseMailer
  helper Ticketing::TicketingHelper
  
  def order_action(action, order, options = nil)
    @order = order
    
    find_tickets
    attach_tickets if should_attach_tickets?
    
    should_mail = true
    if options.present?
      should_mail = self.send(action, options.symbolize_keys)
    else
      should_mail = self.send(action)
    end

    if should_mail != false && @order.email.present?
      mail  to: @order.email,
            subject: t(:subject, scope: [mailer_name, action]),
            template_name: action
    end
  end
  
  private
  
  def confirmation
  end
  
  def payment_received
  end
  
  def overview
  end
  
  def pay_reminder
    @order.transfer? && !@order.paid
  end
  
  def cancellation(options)
    @reason = options[:reason]
  end
  
  def resend_tickets
  end
  
  def find_tickets
    @tickets ||= @order.tickets.cancelled(false)
  end
  
  def attach_tickets
    pdf = TicketsWebPDF.new
    pdf.add_tickets @order.tickets
    attachments['tickets.pdf'] = pdf.render
  end
  
  def should_attach_tickets?
    !@order.cancelled? && (@order.paid || @order.charge?)
  end
  helper_method :should_attach_tickets?
  
  def overview_url
    @overview_url ||= order_overview_url(@order.signed_info(true))
  end
  helper_method :overview_url
end
