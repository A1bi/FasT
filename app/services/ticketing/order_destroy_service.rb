module Ticketing
  class OrderDestroyService
    include NodeUpdating

    def initialize(order)
      @order = order
    end

    def execute
      update_node_with_tickets(@order.tickets) do
        @order.destroy.destroyed?
      end
    end
  end
end
