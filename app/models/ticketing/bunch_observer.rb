module Ticketing
  class BunchObserver < ActiveRecord::Observer
    observe Bunch
  
    def after_update(bunch)
      order = bunch.assignable
      if order.is_a?(Web::Order) && order.pay_method == "transfer" && bunch.paid_changed? && bunch.paid
        OrderMailer.payment_received(order).deliver
      end
    end
  end
end