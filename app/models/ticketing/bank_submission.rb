# frozen_string_literal: true

module Ticketing
  class BankSubmission < ApplicationRecord
    has_many :transactions,
             class_name: 'BankTransaction', foreign_key: :submission_id,
             dependent: :nullify, inverse_of: :submission

    validate :orders_present_on_transactions

    private

    def orders_present_on_transactions
      errors.add(:transactions, :transactions_without_orders) if transactions.any? { |t| t.orders.none? }
    end
  end
end
