module Ticketing
  module Statistics
    extend ActiveSupport::Concern

    def ticket_stats_for_dates(dates)
      Rails.cache.fetch [:ticketing, :statistics, dates, Ticket.all] do
        stats = {
          web: {},
          retail: {
            stores: {},
            total: {}
          },
          box_office: {
            box_offices: {},
            total: {}
          },
          total: {}
        }

        Ticket.includes(:order, :date, :type, :cancellation).where(date: dates).each do |ticket|
          next if ticket.cancelled?

          scopes = [stats[:total]]
          if ticket.order.is_a? Web::Order
            scopes << stats[:web]
          elsif ticket.order.is_a? Retail::Order
            store_scope = stats[:retail][:stores][ticket.order.store_id] ||= {}
            scopes << store_scope
            scopes << stats[:retail][:total]
          elsif ticket.order.is_a? BoxOffice::Order
            store_scope = stats[:box_office][:box_offices][ticket.order.box_office_id] ||= {}
            scopes << store_scope
            scopes << stats[:box_office][:total]
          end

          scopes.each do |scope|
            [scope[ticket.date.id] ||= {}, scope[:total] ||= {}].each do |inner_scope|
              increment_stats_values(inner_scope, ticket.type.id, ticket.price)
            end
          end
        end

        scopes = [stats[:web], stats[:retail][:total], stats[:box_office][:total], stats[:total]]
        Retail::Store.all.each { |store| scopes << stats[:retail][:stores][store.id] }
        BoxOffice::BoxOffice.all.each { |box_office| scopes << stats[:box_office][:box_offices][box_office.id] }

        scopes.each do |scope|
          next if !scope
          dates.each do |date|
            calc_percentage(scope[date.id], [date])
          end
          calc_percentage(scope[:total], dates)
        end

        stats
      end
    end

    private

    def calc_percentage(scope, dates)
      return unless scope.present?
      number_of_seats = dates.sum { |date| date.event.seating.number_of_unreserved_seats_on_date(date) }
      scope[:percentage] = (scope[:total] / number_of_seats.to_f * 100).floor
    end

    def increment_stats_values(scope, ticket_type, ticket_price)
      scope[ticket_type] = (scope[ticket_type] || 0) + 1
      scope[:total] = (scope[:total] || 0) + 1
      scope[:revenue] = (scope[:revenue] || 0) + ticket_price
    end
  end
end
