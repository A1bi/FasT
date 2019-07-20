module Api
  module Ticketing
    module BoxOffice
      class TicketsController < ApplicationController
        before_action :find_tickets, only: %i[show update]

        skip_before_action :verify_authenticity_token

        def show
          send_data printable_data, type: 'application/pdf'
        end

        def update
          cancel_tickets if params.dig(:ticket, :cancelled)

          @tickets.each do |ticket|
            ticket.update(ticket_params)
          end

          head :ok
        end

        private

        def find_tickets
          @tickets = ::Ticketing::Ticket.find(params[:ids])
        end

        def printable_data
          pdf = TicketsBoxOfficePDF.new
          pdf.add_tickets(@tickets)
          pdf.render
        end

        def ticket_params
          params.require(:ticket).permit(:picked_up)
        end

        def cancel_tickets
          ::Ticketing::TicketCancelService.new(
            @tickets, :cancellation_at_box_office
          ).execute(send_customer_email: false)
        end
      end
    end
  end
end
