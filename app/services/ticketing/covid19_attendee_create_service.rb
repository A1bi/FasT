# frozen_string_literal: true

module Ticketing
  class Covid19AttendeeCreateService
    attr_accessor :attendees_params, :order

    def initialize(attendees_params, order)
      @attendees_params = attendees_params || []
      @order = order
    end

    def execute
      attendees_params.each.with_index do |params, i|
        ticket = order.tickets[i]
        next unless ticket&.event&.covid19?

        ticket.build_covid19_attendee(params)
      end
    end
  end
end
