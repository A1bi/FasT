module Ticketing
  class TicketCancelService
    include NodeUpdating

    def initialize(tickets, reason)
      @tickets = tickets
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

    def tickets
      return @tickets if @tickets.is_a? ActiveRecord::Relation

      # we might get an array of records so turn it into a relation
      @tickets = ::Ticketing::Ticket.where(id: @tickets.pluck(:id))
    end

    def valid_tickets
      # need to load and memoize because the valid tickets will be invalid after
      # the first step of cancelling them (see execute method)
      @valid_tickets ||= tickets.cancelled(false).includes(:order).load
    end

    def valid_tickets_by_order
      valid_tickets.group_by(&:order)
    end

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
