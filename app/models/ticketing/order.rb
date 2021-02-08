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

    has_many :tickets, -> { order(:order_index) },
             inverse_of: :order, dependent: :destroy, autosave: true
    belongs_to :date, class_name: 'EventDate', optional: true
    has_random_unique_number :number, min: NUMBER_MIN, max: NUMBER_MAX
    has_many :coupon_redemptions, dependent: :destroy
    has_many :redeemed_coupons, through: :coupon_redemptions, source: :coupon
    has_many :purchased_coupons, class_name: 'Ticketing::Coupon',
                                 foreign_key: :purchased_with_order_id,
                                 inverse_of: :purchased_with_order,
                                 dependent: :nullify, autosave: true
    has_many :exclusive_ticket_type_credit_spendings,
             class_name: 'Members::ExclusiveTicketTypeCreditSpending',
             dependent: :destroy, autosave: true
    has_many :box_office_payments,
             class_name: 'Ticketing::BoxOffice::OrderPayment',
             dependent: :nullify

    validates :tickets, length: { maximum: NUM_TICKETS_MAX }
    validate :items_present

    before_validation :update_date
    before_validation :before_create_validation, on: :create

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

    def edit_ticket_types(tickets, types)
      tickets.each do |ticket|
        ticket.update(type: TicketType.find(types[ticket.id]))
      end
      update_total_and_billing(:ticket_types_edited)
    end

    def cancelled?
      tickets.valid.empty? && purchased_coupons.empty?
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
      # do not use attribute_in_database because total might have already
      # been changed in memory resulting in depositing the same diff twice to
      # the account
      old_total = total

      self.total = tickets.sum do |ticket|
        next 0 if ticket.cancelled?

        ticket.price
      end

      # TODO: as soon as we have an amount history for coupons, this should only
      # use the initial amount
      # this makes sure a coupon redemption will not change the order's total
      #
      # also we have to use &:amount here, because coupons are still only in
      # memory at this point, sum would otherwise make it an SQL query
      self.total += purchased_coupons.sum(&:amount)

      diff = old_total - total
      deposit_into_account(diff, billing_note)
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

    def before_create_validation
      update_total_and_billing(:order_created)

      tickets.each_with_index do |ticket, index|
        ticket.order_index = index + 1
      end
    end

    def update_paid
      self.paid = !billing_account.outstanding?
    end
  end
end
