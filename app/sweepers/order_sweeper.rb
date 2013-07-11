class OrderSweeper < ActionController::Caching::Sweeper
  observe Ticketing::Web::Order, Ticketing::Retail::Order, Ticketing::Bunch
  
  def after_update(record)
    sweep_order_details(record)
    sweep_order_overview
  end
  alias_method :after_destroy, :after_update
  
  def after_create(record)
    sweep_order_overview
  end
  
  def sweep_order_overview
    expire_fragment [:ticketing, :orders, :index]
  end
  
  def sweep_order_details(record)
    bunch = record.is_a? Ticketing::Bunch ? record : record.bunch
    expire_fragment [:ticketing, :orders, :show, bunch.id]
  end
end