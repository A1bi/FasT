module Ticketing
  class StatisticsController < BaseController
    before_filter :prepare_vars
    before_filter :fetch_stats, except: [:seats]
    ignore_restrictions only: [:index_retail]
    
    def index
      @stores = Retail::Store.all
    end
    
    def index_retail
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