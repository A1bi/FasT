module Ticketing
  class TicketsController < BaseController
    before_filter :disable_slides
    before_filter :find_tickets
    ignore_restrictions
    before_filter :restrict_access
    
    def edit_multiple
      case params[:edit_action].to_sym
      when :cancel
        @order.cancel_tickets(@tickets, params[:reason])
      end
      
      update_node_seats_from_tickets(@tickets)
      
      redirect_to_order_details
    end
  
    private
  
    def redirect_to_order_details
      redirect_to orders_path(:ticketing_order, params[:order_id])
    end
  
    def find_tickets
      @order = Ticketing::Order.find(params[:order_id])
      deny_access if retail? && !@order.is_a?(Ticketing::Retail::Order)
      @order.admin_validations = true if admin? && @order.is_a?(Ticketing::Web::Order)
      @tickets = Ticketing::Ticket.find(params[:ticket_ids]).select do |ticket|
        ticket.order == @order && !ticket.cancelled?
      end
    end
    
    def restrict_access
      if (admin? && !@_member.admin?) || (retail? && !@_retail_store.id)
        deny_access
      end
    end
    
    def deny_access
      return redirect_to root_path, alert: t("application.access_denied")
    end
  end
end