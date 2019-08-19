module Ticketing
  class StatisticsController < BaseController
    include Statistics

    ORDER_TYPES_FOR_CHART = [
      Ticketing::Web::Order,
      Ticketing::Retail::Order
    ].freeze

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
      daily_stats.each do |key, value|
        order_klass = key.last.constantize
        next unless ORDER_TYPES_FOR_CHART.include? order_klass

        date_key = key.first.to_date.to_s
        daily_datasets[order_klass][date_key] = value
        daily_datasets[nil][date_key] += value
      end

      render json: {
        labels: daily_dataset_labels,
        datasets: daily_datasets.values.map(&:values)
      }
    end

    private

    def stats_for_event(event)
      ticket_stats_for_dates event.dates
    end
    helper_method :stats_for_event

    def find_events
      @events = Event.current
    end

    def daily_datasets
      @daily_datasets ||=
        # dataset with key nil contains the total over all order types
        ([nil] + ORDER_TYPES_FOR_CHART).each_with_object({}) do |type, sets|
          sets[type] = daily_stats_range.each_with_object({}) do |date, set|
            set[date.to_s] = 0
          end
        end
    end

    def daily_dataset_labels
      daily_stats_range.map.with_index do |date, i|
        format = (i % 7).zero? ? '%a %-d. %B' : '%a %-d.'
        l(date, format: format)
      end
    end

    def daily_stats
      Ticketing::Ticket
        .includes(:order)
        .where('ticketing_tickets.created_at > ?', daily_stats_range.min)
        .group("DATE_TRUNC('day', (ticketing_tickets.created_at::timestamptz)
                AT TIME ZONE '#{Time.zone.tzinfo.name}')")
        .group('ticketing_orders.type')
        .count(:id)
    end

    def daily_stats_range
      18.days.ago.to_date..Time.zone.today
    end
  end
end
