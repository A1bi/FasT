class Ticketing::Mailer
  @queue = :mailer_queue
  def self.perform(order_id, action, options = nil)
    order = Ticketing::Web::Order.find(order_id)
    OrderMailer.order_action(action, order, options).deliver_now
  end
end
