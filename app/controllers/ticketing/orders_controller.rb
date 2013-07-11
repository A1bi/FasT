module Ticketing
  class OrdersController < BaseController
    def index
      types = [
        [:web, Web, [
          
        ]],
        [:retail, Retail, [
          ["includes", :store]
        ]],
        [:unpaid, Web, [
          ["where", ticketing_bunches: { paid: false }]
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
      @order = Ticketing::Bunch.find(params[:id]).assignable
    end
  end
end