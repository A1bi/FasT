module Ticketing
  class EventDate < BaseModel
    include Statistics

    belongs_to :event, touch: true
    has_many :reservations, foreign_key: :date_id

    def self.upcoming
      where('ticketing_event_dates.date > ?', Time.current)
    end

    def sold_out?
      threshold = date.past? ? 97 : 100
      ((ticket_stats_for_dates(event.dates)[:total][id] || {})[:percentage] || 0) >= threshold
    end

    def door_time
      date - 1.hour
    end
  end
end
