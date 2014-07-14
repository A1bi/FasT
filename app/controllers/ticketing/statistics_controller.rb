module Ticketing
  class StatisticsController < BaseController
    include Statistics
    
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
      @stats = ticket_stats_for_dates @dates
    end
    
    def prepare_vars
      @event = Event.current
      @dates = @event.dates
      @ticket_types = TicketType.all
    end
  end
end