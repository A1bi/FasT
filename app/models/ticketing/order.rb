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
    NUM_TICKETS_MAX = 2**8 - 1

    attr_readonly :date

    has_many :tickets, -> { order(:order_index) }, inverse_of: :order, dependent: :destroy, autosave: true
    belongs_to :date, class_name: 'EventDate', optional: true
    has_random_unique_number :number, min: NUMBER_MIN, max: NUMBER_MAX
    has_many :coupon_redemptions, dependent: :destroy
    has_many :redeemed_coupons, through: :coupon_redemptions, source: :coupon
    has_many :purchased_coupons, class_name: 'Ticketing::Coupon',
                                 foreign_key: :purchased_with_order_id,
                                 inverse_of: :purchased_with_order,
                                 dependent: :nullify, autosave: true
    has_many :exclusive_ticket_type_credit_spendings,
             class_name: 'Members::ExclusiveTicketTypeCreditSpending', dependent: :destroy, autosave: true
    has_many :box_office_payments,
             class_name: 'Ticketing::BoxOffice::OrderPayment', dependent: :nullify
    has_many :bank_refunds, dependent: :nullify

    validates :tickets, length: { maximum: NUM_TICKETS_MAX }
    validate :items_present

    before_validation :update_date
    before_validation :set_ticket_order_indexes, on: :create

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

    def cancelled?
      tickets.valid.empty? && purchased_coupons.empty?
    end

    def signed_info(params = {})
      SigningKey.random_active.sign_order(self, params)
    end

    def update_total
      self.total = tickets.sum do |ticket|
        next 0 if ticket.cancelled?

        ticket.price
      end

      self.total += purchased_coupons.sum(&:initial_value)
    end

    def update_paid
      self.paid = !billing_account.outstanding?
    end

    def covid19?
      tickets.any? { |ticket| ticket.event.covid19? }
    end

    def items
      tickets + purchased_coupons
    end

    private

    def items_present
      return if items.any?

      errors.add(:base, :missing_items)
    end

    def update_date
      self[:date_id] = tickets.first&.date_id if tickets.any?
    end

    def set_ticket_order_indexes
      tickets.each_with_index do |ticket, index|
        ticket.order_index = index + 1
      end
    end
  end
end
