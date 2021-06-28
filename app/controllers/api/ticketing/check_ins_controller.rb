# frozen_string_literal: true

module Api
  module Ticketing
    class CheckInsController < ApiController
      include Authenticatable

      def index
        @changed_tickets = changed_tickets
        @signing_keys = ::Ticketing::SigningKey.active
        @ticket_types = ::Ticketing::TicketType.where(event: events)
        @blocks = ::Ticketing::Block.where(seating: seatings)
        @seats = ::Ticketing::Seat.where(block: @blocks)
        @covid19_seats = covid19_seats
      end

      def create
        params[:check_ins].each do |check_in|
          ::Ticketing::TicketCheckInJob.perform_later(
            **check_in.permit(:ticket_id, :date, :medium).to_h.symbolize_keys
          )
        end
        head :created
      end

      private

      def events
        @events ||= ::Ticketing::Event.current
      end

      def dates
        @dates ||= ::Ticketing::EventDate.where(event: events)
      end

      def covid19_dates
        ::Ticketing::EventDate.where(event: events.where(covid19: true))
      end

      def changed_tickets
        ::Ticketing::Ticket.where(date: dates)
                           .where('created_at != updated_at')
                           .or(::Ticketing::Ticket.where(date: covid19_dates))
      end

      def seatings
        ::Ticketing::Seating.find(events.pluck(:seating_id))
      end

      def covid19_seats
        CSV.new(covid19_seats_data, col_sep: ';', headers: true, converters: :numeric)
           .each_with_object({}) do |row, seats|
          seats[row['order_number']] = seat_range(row['seat_number'], row['seat_count'])
        end
      end

      def covid19_seats_data
        Rails.cache.fetch [:ticketing, :covid19_seats_data],
                          expires_in: 15.minutes do
          url = Rails.application.credentials.covid19_seats_url
          URI.parse(url).open(&:read)
        end
      end

      def seat_range(start, count)
        start..(start + count - 1)
      end

      def auth_token
        super || Rails.application.credentials.ticketing_api_auth_token
      end
    end
  end
end
