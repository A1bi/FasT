module Ticketing
  class StatisticsController < BaseController
    include Statistics

    before_action :find_events, only: %i[index index_retail]
    ignore_restrictions only: [:index_retail]

    def index
      @stores = Retail::Store.all
      @box_offices = BoxOffice::BoxOffice.all
    end

    def index_retail
      if !@_retail_store.id
        return redirect_to ticketing_retail_login_path, flash: { warning: t("application.login_required") }
      end
      @transfers = @_retail_store.billing_account.transfers.order(:created_at)
    end

    def seats
      date = Ticketing::EventDate.find params[:date_id]
      seats = if date.event.seating.bound_to_seats?
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

      render_cached_json [:ticketing, :statistics, :seats, date, Ticketing::Seat.all, Ticketing::Ticket.all] do
        { seats: seats }
      end
    end

    def chart_data
      response = {
        labels: [],
        datasets: [{ data: {} }]
      }
      labels = response[:labels]
      datasets = response[:datasets]
      range = 18.days.ago.to_date..Date.today

      tickets = Ticketing::Ticket.where("ticketing_tickets.created_at > ?", range.min)
      stats = Rails.cache.fetch [:ticketing, :statistics, :daily, tickets] do
        if ActiveRecord::Base.connection.adapter_name == "SQLite"
          t = tickets.group("DATE(ticketing_tickets.created_at)")
        else
          t = tickets.group_by_day("ticketing_tickets.created_at")
        end
        t.includes(:order).group("ticketing_orders.type").count(:id)
      end

      order_types = [Ticketing::Web::Order, Ticketing::Retail::Order]

      range.each_with_index do |date, i|
        format = (i % 7 == 0) ? "%a %-d. %B" : "%a %-d."
        labels << l(date, format: format)
        order_types.each_with_index do |_, j|
          ((datasets[j+1] ||= {})[:data] ||= {})[date.to_s] = 0
          datasets.first[:data][date.to_s] = 0
        end
      end

      stats.each do |key, value|
        next if !order_types.include? key.last.constantize
        date_key = key.first.to_date.to_s
        datasets[order_types.index(key.last.constantize) + 1][:data][date_key] = value
        datasets.first[:data][date_key] = datasets.first[:data][date_key] + value
      end

      datasets.each do |set|
        set[:data] = set[:data].values
      end

      render json: response
    end

    private

    def stats_for_event(event)
      ticket_stats_for_dates event.dates
    end
    helper_method :stats_for_event

    def find_events
      @events = Event.current
    end
  end
end
