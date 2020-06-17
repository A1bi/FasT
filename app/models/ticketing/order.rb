# frozen_string_literal: true

module Ticketing
  class Order < ApplicationRecord
    include Billable
    include RandomUniqueAttribute
    include Loggable

    # binary ticket info reserves 20 bits for number
    NUMBER_DIGITS = Math.log10(2**20).floor
    NUMBER_MIN = 10**(NUMBER_DIGITS - 1)
    NUMBER_MAX = 10**NUMBER_DIGITS - 1
    # binary ticket info reserves 8 bits for index
    NUM_TICKETS_MAX = 2**8

    attr_readonly :date

    has_many :tickets, -> { order(:order_index) },
             inverse_of: :order, dependent: :destroy, autosave: true
    belongs_to :date, class_name: 'EventDate'
    has_random_unique_number :number, min: NUMBER_MIN, max: NUMBER_MAX
    has_many :coupon_redemptions, dependent: :destroy
    has_many :coupons, through: :coupon_redemptions
    has_many :exclusive_ticket_type_credit_spendings,
             class_name: 'Members::ExclusiveTicketTypeCreditSpending',
             dependent: :destroy, autosave: true
    has_many :box_office_payments,
             class_name: 'Ticketing::BoxOffice::OrderPayment',
             dependent: :nullify

    validates :tickets, length: { in: 1..NUM_TICKETS_MAX }
    validates :date, presence: true

    before_validation :update_date
    before_validation :before_create_validation, on: :create
    before_create :log_created
    before_update :log_updated

    delegate :event, to: :date, allow_nil: true
    delegate :balance, to: :billing_account

    class << self
      def unpaid
        where(paid: false)
      end

      def event_today
        joins(tickets: :date)
          .where(
            ticketing_tickets: {
              cancellation_id: nil
            },
            ticketing_event_dates: {
              date: Time.zone.today.all_day
            }
          )
          .distinct
      end

      def policy_class
        OrderPolicy
      end
    end

    def mark_as_paid
      return if paid

      withdraw_from_account(billing_account.balance, :payment_received)
      log(:marked_as_paid)
    end

    def edit_ticket_types(tickets, types)
      tickets.each do |ticket|
        ticket.update(type: TicketType.find(types[ticket.id]))
      end
      update_total_and_billing(:ticket_types_edited)
      log(:ticket_types_edited, { count: tickets.count })
    end

    def cancelled?
      tickets.cancelled(false).empty?
    end

    def transfer_refund
      withdraw_from_account(billing_account.balance, :transfer_refund)
    end

    def correct_balance(amount)
      deposit_into_account(amount, :correction)
    end

    def signed_info(params = {})
      SigningKey.random_active.sign_order(self, params)
    end

    def after_account_transfer
      update_paid
    end

    def update_total_and_billing(billing_note)
      old_total = total

      self.total = 0
      tickets.each do |ticket|
        self.total = total.to_f + ticket.price.to_f unless ticket.cancelled?
      end

      diff = old_total - total
      deposit_into_account(diff, billing_note)
    end

    def covid19?
      tickets.any? { |ticket| ticket.event.covid19? }
    end

    private

    def update_date
      self[:date_id] = tickets.first&.date_id
    end

    def before_create_validation
      update_total_and_billing(:order_created)

      tickets.each_with_index do |ticket, index|
        ticket.order_index = index + 1
      end
    end

    def log_created
      log(:created)
    end

    def log_updated
      log(:updated) if (changed_attribute_names_to_save -
                        %w[paid total updated_at]).any?
    end

    def update_paid
      self.paid = !billing_account.outstanding?
    end
  end
end
