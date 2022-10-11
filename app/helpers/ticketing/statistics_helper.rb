# frozen_string_literal: true

module Ticketing
  module StatisticsHelper
    def options_for_events(events, current_event)
      disabled = []
      events = events.map do |event|
        disabled << event.slug if event.archived? && event.tickets.none?
        ["#{event.dates.first.date.year} – #{event.name}", event.slug]
      end
      options_for_select(events, selected: current_event.slug, disabled:)
    end
  end
end
