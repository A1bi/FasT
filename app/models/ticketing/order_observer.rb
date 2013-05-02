module Ticketing
  class OrderObserver < ActiveRecord::Observer
    observe Web::Order, Retail::Order
  
    def after_save(order)
      updateRetailManager(order)
    end
    alias_method :after_destroy, :after_save
    
    private
    
    def updateRetailManager(order)
      if order.class == Retail::Order
        NodeApi.push_to_retail_manager("updateOrders", order.store.id)
      end
    end
  end
end