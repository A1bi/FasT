# frozen_string_literal: true

module Api
  module Ticketing
    module BoxOffice
      class TicketsController < BaseController
        before_action :find_tickets, only: %i[show update]

        def show
          send_data printable_data, type: 'application/pdf'
        end

        def update
          cancel_tickets if params.dig(:ticket, :cancelled)
          update_tickets

          head :ok
        end

        private

        def find_tickets
          # where is necessary here (instead of find) because we need a relation later
          @tickets = ::Ticketing::Ticket.where(id: params[:ids])
        end

        def printable_data
          pdf = ::Ticketing::TicketsBoxOfficePdf.new
          pdf.add_tickets(@tickets)
          pdf.render
        end

        def ticket_params
          params.require(:ticket).permit(:picked_up, :resale)
        end

        def update_tickets
          ::Ticketing::TicketUpdateService.new(@tickets, params: ticket_params).execute
        end

        def cancel_tickets
          ::Ticketing::TicketCancelService.new(@tickets, reason: :box_office).execute(send_customer_email: false)
        end
      end
    end
  end
end
