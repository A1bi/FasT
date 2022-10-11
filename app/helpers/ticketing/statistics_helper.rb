# frozen_string_literal: true

module Ticketing
  module StatisticsHelper
    def options_for_events(events, current_event)
      disabled = []
      events = events.map do |event|
        year = event.dates.first.date.year
        disabled << event.slug if event.archived? && event.tickets.none?
        [year, "#{year} – #{event.name}", event.slug]
      end
      events.sort_by! { |event| event[0] }.reverse!
      options_for_select(events.map { |event| event[1..2] }, selected: current_event.slug, disabled:)
    end
  end
end
