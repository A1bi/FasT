# frozen_string_literal: true

module Ticketing
  module StatisticsHelper
    def format_percentage(scope)
      number_to_percentage(scope&.dig(:percentage) || 0, precision: 0)
    end

    def format_revenue(scope)
      number_to_currency(scope&.dig(:revenue) || 0)
    end

    def format_number(total)
      number_with_delimiter(total || 0)
    end

    def options_for_events(events, current_event)
      events = events.map do |event|
        ["#{event.dates.first.date.year} – #{event.name}", event.slug]
      end
      options_for_select(events, selected: current_event.slug)
    end
  end
end
