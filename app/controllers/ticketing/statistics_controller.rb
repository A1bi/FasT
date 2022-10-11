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

    def index
      @events = Event.ordered_by_dates(:desc)
      return redirect_to slug: @events.first.slug if params[:slug].nil?

      @event = Event.find_by!(slug: params[:slug])

      if current_user.admin?
        @stores = Retail::Store.all
        @box_offices = BoxOffice::BoxOffice.all
        render :index_admin

      elsif current_user.retail?
        @transactions = current_user.store.billing_account.transactions
        render :index_retail
      end
    end

    def seats
      date = Ticketing::EventDate.find params[:date_id]

      render_cached_json seats_cache_key(date) do
        seats = if date.event.seating.plan?
                  Ticketing::Seat.with_booked_status_on_date(date).map do |seat|
                    status = if seat.taken?
                               0
                             elsif seat.reserved?
                               2
                             else
                               1
                             end
                    [seat.id, status]
                  end
                else
                  []
                end

        { seats: }
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
      ticket_stats_for_event event
    end
    helper_method :stats_for_event

    def chart_dates
      @chart_dates ||= 18.days.ago.to_date..Time.zone.today
    end

    def chart_datasets
      @chart_datasets ||= ORDER_TYPES_FOR_CHART.index_with do
        chart_dates.index_with { 0 }
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
