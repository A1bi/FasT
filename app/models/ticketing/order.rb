module Ticketing
  class Order < BaseModel
  	include Loggable, RandomUniqueAttribute, Billable

  	has_many :tickets, dependent: :destroy, autosave: true
    has_random_unique_number :number, 6
    has_many :coupon_redemptions, dependent: :destroy
    has_many :coupons, through: :coupon_redemptions

  	validates_length_of :tickets, minimum: 1

    before_validation :before_create_validation, on: :create
    before_create :before_create

    def number
      "1#{self[:number]}"
    end

    def self.api_hash(details = [], ticket_details = [])
      includes({ tickets: [:seat, :date] }).all.map { |order| order.api_hash(details, tickets_details) }
    end

    def api_hash(details = [], ticket_details = [])
      hash = {
        id: id.to_s,
        number: number.to_s,
        total: total.to_f,
        paid: paid || false,
        created: created_at.to_i,
      }
      hash[:tickets] = tickets.map { |ticket| ticket.api_hash(ticket_details) } if details.include? :tickets
      hash.merge(super(details))
    end

    def mark_as_paid
      return if paid
      withdraw_from_account(billing_account.balance, :payment_received)
      log(:marked_as_paid)
    end

    def cancel_tickets(tickets, reason)
      tickets.reject! { |t| t.cancelled? }
      cancellation = nil
      tickets.each do |ticket|
        cancellation = ticket.cancel(cancellation || reason)
      end
      update_total_and_billing(:cancellation)
      log(:tickets_cancelled, { count: tickets.count, reason: reason })
    end
    
    def edit_ticket_types(tickets, types)
      tickets.reject! { |t| t.cancelled? }
      tickets.each do |ticket|
        ticket.type = TicketType.find(types[ticket.id])
      end
      update_total_and_billing(:ticket_types_edited)
      log(:ticket_types_edited, { count: tickets.count })
    end

    def cancelled?
      tickets.cancelled(false).empty?
    end

    private

    def before_create_validation
      update_total_and_billing(:order_created)
      true
    end

    def before_create
      log(:created)
      true
    end

    def update_total_and_billing(billing_note)
      old_total = self.total

      self.total = 0
      tickets.each do |ticket|
        self.total = total.to_f + ticket.price.to_f if !ticket.cancelled?
      end

      diff = old_total - self.total
      deposit_into_account(diff, billing_note)
    end

    def update_paid
      self.paid = !billing_account.outstanding?
    end

    def after_account_transfer
      update_paid
    end
  end
end
