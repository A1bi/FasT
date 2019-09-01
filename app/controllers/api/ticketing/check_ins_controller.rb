module Api
  module Ticketing
    class CheckInsController < ApiController
      def index
        @signing_keys = ::Ticketing::SigningKey.active
        @dates = ::Ticketing::EventDate.where(event: events)
        @ticket_types = ::Ticketing::TicketType.where(event: events)
        @changed_tickets = ::Ticketing::Ticket.where(date: @dates)
                                              .where('created_at != updated_at')
      end

      def create
        ActiveRecord::Base.transaction do
          params[:check_ins].each do |check_in|
            ticket = ::Ticketing::Ticket.find(check_in[:ticket_id])
            next if ticket.check_ins.create(check_in.permit(:date, :medium))

            raise ActiveRecord::RecordInvalid
          end
        end

        head :created
      rescue ActiveRecord::RecordInvalid
        head :unprocessable_entity
      end

      private

      def events
        @events ||= ::Ticketing::Event.current
      end
    end
  end
end
