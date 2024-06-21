# frozen_string_literal: true

module Ticketing
  class StripeTransaction < ApplicationRecord
    self.inheritance_column = nil

    belongs_to :order

    enum :type, %i[payment_intent refund]
    enum :method, %i[apple_pay google_pay]

    validates :type, :stripe_id, :amount, presence: true
    validates :amount, numericality: { other_than: 0 }
  end
end
