class Ticketing::Mailer
  @queue = :mailer_queue
  def self.perform(order_id, action)
    order = Ticketing::Web::Order.find(order_id)
    OrderMailer.send(action, order).deliver
  end
end