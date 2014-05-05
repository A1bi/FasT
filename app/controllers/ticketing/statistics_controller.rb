module Ticketing
  class StatisticsController < BaseController
    before_filter :fetch_stats
    before_filter :prepare_vars
    ignore_restrictions only: [:index_retail]
    
    def index
      @stores = Retail::Store.all
      
      @seats = Rails.cache.fetch [:ticketing, :statistics, Seat] do
        Hash[@dates.map { |date| [date.id, Seat.with_availability_on_date(date)] }]
      end
    end
    
    def index_retail
    end
    
    private
    
    def fetch_stats
      @stats = Rails.cache.fetch [:ticketing, :statistics, Ticket] do
        stats = {
          web: {},
          retail: {
            stores: {},
            total: {}
          },
          total: {}
        }
        
        Order.includes(tickets: [:date, :type]).each do |order|
          next if order.cancelled?
          
          scopes = [stats[:total]]
          if order.is_a? Web::Order
            scopes << stats[:web]
          elsif order.is_a? Retail::Order
            scopes << ((stats[:retail][:stores] ||= {})[order.store.id] ||= {})
            scopes << stats[:retail][:total]
          end
          
          order.tickets.each do |ticket|
            next if ticket.cancelled?
            
            scopes.each do |scope|
              (scope[ticket.date.id] ||= {})[ticket.type.id] = (scope[ticket.date.id][ticket.type.id] || 0).next
              scope[ticket.date.id][:total] = (scope[ticket.date.id][:total] || 0).next
              scope[ticket.date.id][:revenue] = (scope[ticket.date.id][:revenue] || 0) + ticket.price
              (scope[:total] ||= {})[ticket.type.id] = (scope[:total][ticket.type.id] || 0).next
              scope[:total][:total] = (scope[:total][:total] || 0).next
              scope[:total][:revenue] = (scope[:total][:revenue] || 0) + ticket.price
            end
          end
          
        end
        
        stats
      end
      
      def prepare_vars
        @dates = Event.current.dates
        @ticket_types = TicketType.all
      end
    end
  end
end