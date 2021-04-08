# frozen_string_literal: true

module Ticketing
  class Coupon < ApplicationRecord
    include RandomUniqueAttribute
    include Billable
    include Loggable

    has_random_unique_token :code, 6
    has_many :redemptions, class_name: 'Ticketing::CouponRedemption',
                           dependent: :destroy
    belongs_to :purchased_with_order, class_name: 'Ticketing::Order',
                                      optional: true, autosave: false
    has_many :orders, through: :redemptions

    class << self
      def valid
        joins(:billing_account)
          .where('expires_at IS NULL OR expires_at > ?', Time.current)
          .where('free_tickets > 0 OR ticketing_billing_accounts.balance > 0')
      end

      def expired
        joins(:billing_account)
          .where('expires_at < ?', Time.current)
          .or(where('free_tickets <= 0 AND ' \
                    'ticketing_billing_accounts.balance <= 0'))
      end
    end

    def expired?
      return true if free_tickets < 1 && !billing_account.credit?

      expires_at&.past?
    end

    def value
      billing_account.balance
    end

    def initial_value
      return value if new_record?

      transaction = billing_account.transactions.reorder(:created_at).first
      transaction ? transaction.amount : 0
    end
  end
end
