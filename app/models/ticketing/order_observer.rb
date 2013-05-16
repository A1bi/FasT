module Ticketing
  class OrderObserver < ActiveRecord::Observer
    observe Web::Order, Retail::Order
  
    def after_save(order)
      update_retail_checkout(order)
    end
    alias_method :after_destroy, :after_save
    
    def after_create(order)
      OrderMailer.confirmation(order).deliver if order.is_a? Web::Order
    end
    
    private
    
    def update_retail_checkout(order)
      if order.is_a? Retail::Order
        NodeApi.push_to_retail_checkout("updateOrders", order.store.id, Retail::Order.by_store(order.store).api_hash)
      end
    end
  end
end