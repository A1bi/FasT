module Ticketing
  class Event < BaseModel
    include Statistics

    has_many :dates, -> { order(:date) }, class_name: 'EventDate',
                                          inverse_of: :event
    has_many :ticket_types, dependent: :destroy
    belongs_to :seating

    def self.current
      archived(false)
    end

    def self.archived(archived = true)
      where(archived: archived)
    end

    def self.with_future_dates
      joins(:dates).merge(EventDate.upcoming)
                   .where.not(ticketing_event_dates: { id: nil }).distinct
    end

    def sold_out?
      ((ticket_stats_for_dates(dates)[:total][:total] || {})[:percentage] || 0) >= 100
    end

    def sale_started?
      sale_start.nil? || Time.current > sale_start
    end

    def sale_ended?
      dates.maximum(:date) < Time.current
    end

    def on_sale?
      sale_started? && !sale_ended?
    end

    def sale_disabled?
      sale_disabled_message.present?
    end
  end
end
