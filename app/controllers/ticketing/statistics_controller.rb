module Ticketing
  class StatisticsController < BaseController
    before_filter :prepare_vars
    before_filter :fetch_stats, except: [:seats]
    ignore_restrictions only: [:index_retail]
    
    def index
      @stores = Retail::Store.all
    end
    
    def index_retail
      redirect_to root_path if !@_retail_store.id
    end
    
    def seats
      render_cached_json [:ticketing, :statistics, :seats, @dates, Ticketing::Seat, Ticketing::Ticket] do
        {
          seats: Hash[@dates.map do |date|
            [date.id, Hash[Ticketing::Seat.with_availability_on_date(date).map do |seat|
              [seat.id, !seat.taken? ? 1 : 0]
            end]]
          end]
        }
      end
    end
    
    def chart_data
      response = {
        labels: [],
        datasets: []
      }
      labels = response[:labels]
      datasets = response[:datasets]
      start = Date.today - 2.weeks
      
      tickets = Ticketing::Ticket.where("ticketing_tickets.created_at > ?", start)
      stats = Rails.cache.fetch [:ticketing, :statistics, :daily, tickets] do
        tickets.includes(:order).group("DATE(ticketing_tickets.created_at)").group("ticketing_orders.type").count(:id)
      end
      
      order_types = [Ticketing::Web::Order, Ticketing::Retail::Order]
      
      (start..Date.today).each_with_index do |date, i|
        format = (i % 7 == 0) ? "%a %e. %B" : "%a %e."
        labels << l(date, format: format)
        order_types.each_with_index do |_, i|
          ((datasets[i] ||= {})[:data] ||= {})[date.to_s] = 0
        end
      end
      
      stats.each do |key, value|
        (datasets[order_types.index(key.last.constantize)] ||= { data: [] })[:data][key.first.to_s] = value
      end
      
      datasets.each do |set|
        set[:data] = set[:data].values
      end
      
      render json: response
    end
    
    private
    
    def fetch_stats
      @stats = Rails.cache.fetch [:ticketing, :statistics, @dates, Ticket] do
        stats = {
          web: {},
          retail: {
            stores: {},
            total: {}
          },
          total: {}
        }
        
        Ticket.includes(:order, :date, :type, :cancellation).where(date: @dates).each do |ticket|
          next if ticket.cancelled?
          
          scopes = [stats[:total]]
          if ticket.order.is_a? Web::Order
            scopes << stats[:web]
          elsif ticket.order.is_a? Retail::Order
            scopes << ((stats[:retail][:stores] ||= {})[ticket.order.store_id] ||= {})
            scopes << stats[:retail][:total]
          end
            
          scopes.each do |scope|
            (scope[ticket.date.id] ||= {})[ticket.type.id] = (scope[ticket.date.id][ticket.type.id] || 0).next
            scope[ticket.date.id][:total] = (scope[ticket.date.id][:total] || 0).next
            scope[ticket.date.id][:revenue] = (scope[ticket.date.id][:revenue] || 0) + ticket.price
            (scope[:total] ||= {})[ticket.type.id] = (scope[:total][ticket.type.id] || 0).next
            scope[:total][:total] = (scope[:total][:total] || 0).next
            scope[:total][:revenue] = (scope[:total][:revenue] || 0) + ticket.price
          end
        end
        
        stats
      end
    end
    
    def prepare_vars
      @event = Event.current
      @dates = @event.dates
      @ticket_types = TicketType.all
    end
  end
end