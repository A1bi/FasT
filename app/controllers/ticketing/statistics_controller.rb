# frozen_string_literal: true

module Ticketing
  class StatisticsController < BaseController
    include Statistics

    ORDER_TYPES_FOR_CHART = [
      Ticketing::Web::Order,
      Ticketing::Retail::Order,
      Ticketing::BoxOffice::Order
    ].freeze

    before_action :authorize
    before_action :find_events, only: :index

    def index
      if current_user.admin?
        @stores = Retail::Store.all
        @box_offices = BoxOffice::BoxOffice.all
        render :index_admin

      elsif current_user.retail?
        @transfers = current_user.store.billing_account
                                 .transfers.order(:created_at)
        render :index_retail
      end
    end

    def seats
      date = Ticketing::EventDate.find params[:date_id]

      render_cached_json seats_cache_key(date) do
        seats = if date.event.seating.plan?
                  Ticketing::Seat.with_booked_status_on_date(date).map do |seat|
                    status = if !seat.taken?
                               seat.reserved? ? 2 : 1
                             else
                               0
                             end
                    [seat.id, status]
                  end
                else
                  []
                end

        { seats: seats }
      end
    end

    def chart_data
      daily_stats.each do |key, value|
        order_type = key.last.constantize
        next unless ORDER_TYPES_FOR_CHART.include? order_type

        date_key = key.first.to_date
        chart_datasets[order_type][date_key] = value
      end
    end

    private

    def stats_for_event(event)
      ticket_stats_for_dates event.dates
    end
    helper_method :stats_for_event

    def find_events
      @events = Event.current
    end

    def chart_dates
      @chart_dates ||= 18.days.ago.to_date..Time.zone.today
    end

    def chart_datasets
      @chart_datasets ||=
        ORDER_TYPES_FOR_CHART.each_with_object({}) do |type, datasets|
          datasets[type] = chart_dates.each_with_object({}) do |date, dataset|
            dataset[date] = 0
          end
        end
    end

    def daily_stats
      Ticketing::Ticket
        .includes(:order)
        .where('ticketing_tickets.created_at > ?', chart_dates.min)
        .group("DATE_TRUNC('day', (ticketing_tickets.created_at::timestamptz)
                AT TIME ZONE '#{Time.zone.tzinfo.name}')")
        .group('ticketing_orders.type')
        .count(:id)
    end

    def seats_cache_key(date)
      [
        :ticketing, :statistics, :seats,
        date, Ticketing::Seat.all, Ticketing::Ticket.all
      ]
    end

    def authorize
      super %i[ticketing statistics]
    end
  end
end
