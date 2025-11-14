# frozen_string_literal: true

module Ticketing
  module Customer
    class OrdersController < BaseController
      skip_authorization

      before_action :redirect_unauthenticated, except: %i[show check_email]
      before_action :determine_transferability, only: :show
      before_action :determine_cancellability, only: :show

      helper Ticketing::TicketingHelper

      def show
        render :email_form unless @authenticated
      end

      def check_email
        return redirect_to authenticated_overview_path if email_correct?

        redirect_to request.path, alert: t('.wrong_email')
      end

      def tickets
        tickets = @order.tickets.valid
        tickets.where!(id: params[:id]) if params[:id].present? # we need a relation for TicketsWebPdf
        return head :not_found if tickets.none?
        return head :forbidden unless tickets_accessible?

        respond_to do |format|
          format.pdf do
            pdf = TicketsWebPdf.new
            pdf.add_tickets(tickets)
            send_data pdf.render, filename: 'Ticket.pdf', disposition: 'inline'
          end
          format.pkpass do
            send_file tickets.first.passbook_pass(create: true).file_path, filename: 'Ticket.pkpass'
          end
          format.pkpasses do
            send_data wallet_passes_file(tickets).read, filename: 'Tickets.pkpasses'
          end
        end
      end

      def seats
        render json: seats_hash
      end

      private

      def wallet_passes_file(tickets)
        stream = Zip::OutputStream.write_buffer do |zip|
          tickets.each.with_index do |ticket, i|
            pass = ticket.passbook_pass(create: true)
            zip.put_next_entry("#{i}.pkpass")
            zip.write(File.binread(pass.file_path))
          end
        end
        stream.rewind
        stream
      end

      def seats_hash
        types = [[:chosen, @order], [:taken, @order.date]]
        types.each_with_object({}) do |type, obj|
          obj[type.first] = type.last.tickets.where(invalidated: false)
                                .filter_map(&:seat_id)
        end
      end

      def email_correct?
        web_order? && @order.email.present? && @order.email == params[:email]
      end

      def authenticated_overview_path
        customer_order_overview_path(@order.signed_info(authenticated: true))
      end

      def tickets_accessible?
        @order.paid?
      end
      helper_method :tickets_accessible?
    end
  end
end
