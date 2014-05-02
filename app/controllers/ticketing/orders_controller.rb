module Ticketing
  class OrdersController < BaseController
    before_filter :find_order, only: [:show, :mark_as_paid, :send_pay_reminder, :resend_tickets, :approve, :cancel]
    
    def index
      types = [
        [:web, Web, []],
        [:retail, Retail, [
          [:includes, :store]
        ]]
      ]
      @orders = {}
      types.each do |type|
        @orders[type[0]] = type[1]::Order
          .includes(:tickets)
          .order(created_at: :desc)
          .limit(20)
        type[2].each do |additional|
          @orders[type[0]] = @orders[type[0]].send(additional[0], additional[1])
        end
      end
    end
    
    def show
    end
    
    def mark_as_paid
      @order.mark_as_paid if !@order.cancelled?
      redirect_to_order_details
    end
    
    def approve
      @order.approve if !@order.cancelled?
      redirect_to_order_details
    end
    
    def send_pay_reminder
      @order.send_pay_reminder if @order.is_a?(Ticketing::Web::Order) && !@order.cancelled?
      redirect_to_order_details
    end
    
    def resend_tickets
      @order.resend_tickets if @order.is_a? Ticketing::Web::Order
      redirect_to_order_details
    end
    
    def cancel
      @order.cancel(params[:reason])
      @order.log(:cancelled)
      
      seats = {}
      @order.tickets.each do |ticket|
        ticket.cancellation = @order.cancellation
        ticket.save
        seats.deep_merge! ticket.date_id => Hash[[ticket.seat.node_hash(ticket.date_id)]]
      end
      NodeApi.update_seats(seats)
      
      OrderMailer.cancellation(@order).deliver
      
      redirect_to ticketing_order_path(@order)
    end
    
    private
    
    def redirect_to_order_details
      redirect_to ticketing_order_path(@order)
    end
    
    def find_order
      @order = Ticketing::Order.find(params[:id])
    end
  end
end