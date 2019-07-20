module Ticketing
  class TicketCancelService < TicketBaseService
    def initialize(tickets, reason)
      super(tickets)
      @reason = reason
    end

    def execute(send_customer_email: true)
      ActiveRecord::Base.transaction do
        valid_tickets.inject(nil) do |cancellation, ticket|
          ticket.cancel(cancellation || @reason)
        end

        valid_tickets_by_order.each do |order, tickets|
          next unless update_order(order, tickets)

          send_email(order) if send_customer_email
        end

        update_node_with_tickets(@tickets)
      end

      # return copy so a count wouldn't reload and thus make it empty
      valid_tickets.to_a
    end

    private

    def update_order(order, tickets)
      order.update_total_and_billing(:cancellation)
      order.log(:tickets_cancelled, count: tickets.count, reason: @reason)
      order.save
    end

    def send_email(order)
      order.enqueue_mailing(:cancellation,
                            depends_on_commit: true, reason: @reason.to_s)
    end
  end
end
