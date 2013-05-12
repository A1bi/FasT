module Ticketing
  class OrderObserver < ActiveRecord::Observer
    observe Web::Order, Retail::Order
  
    def after_save(order)
      update_retail_checkout(order)
    end
    alias_method :after_destroy, :after_save
    
    private
    
    def update_retail_checkout(order)
      if order.class == Retail::Order
        NodeApi.push_to_retail_checkout("updateOrders", order.store.id, Retail::Order.by_store(order.store).api_hash)
      end
    end
  end
end