module Ticketing
  class Event < BaseModel
    include Statistics

    has_many :dates, class_name: EventDate
    belongs_to :seating

    def self.by_identifier(id)
      where(identifier: id).first
    end

    def self.current
      last
    end

    def sold_out?
      ((ticket_stats_for_dates(dates)[:total][:total] || {})[:percentage] || 0) >= 100
    end

    def sale_started?
      sale_start.nil? || Time.now > sale_start
    end
  end
end
