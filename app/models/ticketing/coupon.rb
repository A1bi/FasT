# frozen_string_literal: true

module Ticketing
  class Coupon < ApplicationRecord
    include RandomUniqueAttribute
    include Billable
    include Loggable

    enum :value_type, %i[free_tickets credit], suffix: :value

    has_random_unique_token :code, 6
    has_many :redemptions, class_name: 'Ticketing::CouponRedemption', dependent: :destroy
    belongs_to :purchased_with_order, class_name: 'Ticketing::Order', optional: true, autosave: false
    has_many :orders, through: :redemptions

    class << self
      def valid
        with_credit.where('expires_at IS NULL OR expires_at > ?', Time.current)
      end

      def expired
        merge(valid.invert_where)
      end

      def with_codes(codes)
        join = 'JOIN unnest(ARRAY[?]) WITH ORDINALITY t(code, ord) USING (code)'
        joins(sanitize_sql_array([join, codes.uniq])).order('t.ord')
      end
    end

    def expired?
      expires_at&.past? || !billing_account.credit?
    end

    def value
      billing_account.balance
    end

    def initial_value
      return value if new_record?

      transaction = billing_account.transactions.reorder(:created_at).first
      transaction ? transaction.amount : 0
    end

    def free_tickets
      free_tickets_value? ? value.to_i : 0
    end

    def credit
      credit_value? ? value : 0
    end
  end
end
