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
              [seat.id, !seat.taken? ? (seat.reserved? ? 2 : 1) : 0]
            end]]
          end]
        }
      end
    end
    
    def chart_data
      response = {
        labels: [],
        datasets: [{ data: {} }]
      }
      labels = response[:labels]
      datasets = response[:datasets]
      start = Date.today - 18.days
      
      tickets = Ticketing::Ticket.where("ticketing_tickets.created_at > ?", start)
      stats = Rails.cache.fetch [:ticketing, :statistics, :daily, tickets] do
        tickets.includes(:order).group("DATE(ticketing_tickets.created_at)").group("ticketing_orders.type").count(:id)
      end
      
      order_types = [Ticketing::Web::Order, Ticketing::Retail::Order]
      
      (start..Date.today).each_with_index do |date, i|
        format = (i % 7 == 0) ? "%a %e. %B" : "%a %e."
        labels << l(date, format: format)
        order_types.each_with_index do |_, j|
          ((datasets[j+1] ||= {})[:data] ||= {})[date.to_s] = 0
          datasets.first[:data][date.to_s] = 0
        end
      end
      
      stats.each do |key, value|
        datasets[order_types.index(key.last.constantize) + 1][:data][key.first.to_s] = value
        datasets.first[:data][key.first.to_s] = datasets.first[:data][key.first.to_s] + value
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
            store_scope = stats[:retail][:stores][ticket.order.store_id] ||= {}
            scopes << store_scope
            scopes << stats[:retail][:total]
          end
            
          scopes.each do |scope|
            [scope[ticket.date.id] ||= {}, scope[:total] ||= {}].each do |inner_scope|
              increment_stats_values(inner_scope, ticket.type.id, ticket.price)
            end
          end
        end
        
        scopes = [stats[:web], stats[:retail][:total], stats[:total]]
        Retail::Store.all.each { |store| scopes << stats[:retail][:stores][store.id] }
        scopes.each do |scope|
          next if !scope
          @dates.each do |date|
            calc_percentage(scope[date.id], false)
          end
          calc_percentage(scope[:total], true)
        end
        
        stats
      end
    end
    
    def increment_stats_values(scope, ticket_type, ticket_price)
      scope[ticket_type] = (scope[ticket_type] || 0) + 1
      scope[:total] = (scope[:total] || 0) + 1
      scope[:revenue] = (scope[:revenue] || 0) + ticket_price
    end
    
    def calc_percentage(scope, all_dates)
      return if !scope
      @seats ||= Seat.count.to_f
      scope[:percentage] = (scope[:total] / (@seats * (all_dates ? @dates.count : 1)) * 100).floor
    end
    
    def prepare_vars
      @event = Event.current
      @dates = @event.dates
      @ticket_types = TicketType.all
    end
  end
end