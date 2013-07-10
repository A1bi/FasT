module Ticketing
  class StatisticsController < BaseController
    def index
      @dates = Ticketing::Event.current.dates
      @ticket_types = Ticketing::TicketType.scoped
      @stores = Ticketing::Retail::Store.scoped
      
      @stats = Rails.cache.fetch [:ticketing, :statistics, :tickets] do
        stats = {
          web: {},
          retail: {
            stores: {},
            total: {}
          },
          total: {}
        }
        
        Ticketing::Bunch.includes(:assignable, tickets: [:date, :type]).each do |bunch|
          next if bunch.cancelled?
          
          scopes = [stats[:total]]
          if bunch.assignable.is_a? Ticketing::Web::Order
            scopes << stats[:web]
          elsif bunch.assignable.is_a? Ticketing::Retail::Order
            scopes << ((stats[:retail][:stores] ||= {})[bunch.assignable.store.id] ||= {})
            scopes << stats[:retail][:total]
          end
          
          bunch.tickets.each do |ticket|
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
    end
  end
end