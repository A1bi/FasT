module Ticketing
  class OrdersController < BaseController
    before_filter :find_bunch, only: [:show, :mark_as_paid, :send_pay_reminder, :approve]
    after_filter :sweep_details_cache, only: [:mark_as_paid, :send_pay_reminder, :approve]
    
    def index
      types = [
        [:web, Web, []],
        [:retail, Retail, [
          ["includes", :store]
        ]]
      ]
      @orders = {}
      types.each do |type|
        @orders[type[0]] = type[1]::Order
          .includes(bunch: [:tickets])
          .where(ticketing_tickets: { cancellation_id: nil })
          .order("#{type[1]::Order.table_name}.created_at DESC")
          .limit(20)
        type[2].each do |additional|
          @orders[type[0]] = @orders[type[0]].send(additional[0], additional[1])
        end
      end
    end
    
    def show
    end
    
    def mark_as_paid
      @bunch.assignable.mark_as_paid
      redirect_to_order_details
    end
    
    def approve
      @bunch.assignable.approve
      redirect_to_order_details
    end
    
    def send_pay_reminder
      @bunch.assignable.send_pay_reminder if @bunch.assignable.is_a? Ticketing::Web::Order
      redirect_to_order_details
    end
    
    private
    
    def redirect_to_order_details
      redirect_to ticketing_order_path(@bunch)
    end
    
    def find_bunch
      @bunch = Ticketing::Bunch.find(params[:id])
    end
    
    def sweep_details_cache
      expire_fragment [:ticketing, :orders, :show, @bunch.id]
    end
  end
end