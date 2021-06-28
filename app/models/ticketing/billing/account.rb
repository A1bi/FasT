# frozen_string_literal: true

module Ticketing
  module Billing
    class Account < ApplicationRecord
      belongs_to :billable, polymorphic: true, inverse_of: :billing_account
      has_many :transactions, -> { order(:created_at) }, inverse_of: :account, dependent: :destroy

      validates :balance, numericality: true

      def deposit(amount, note_key)
        return if amount.zero?

        update_balance(amount)

        create_transaction(amount: amount, note_key: note_key)
      end

      def withdraw(amount, note_key)
        deposit(-amount, note_key)
      end

      def transfer(participant, amount, note_key, reverse_transaction = nil)
        return if amount.zero? || participant == self

        update_balance(-amount)

        create_transaction(participant: participant, amount: -amount, note_key: note_key) do |t|
          t.reverse_transaction = reverse_transaction || participant.transfer(self, -amount, note_key, t)
        end
      end

      def outstanding?
        balance.negative?
      end

      def credit?
        balance.positive?
      end

      private

      def update_balance(amount)
        self[:balance] += amount
        save! if persisted?
      end

      def create_transaction(attrs)
        t = transactions.new(attrs)
        yield t if block_given?
        t.save! if persisted? && (!t.participant || t.participant.persisted?)
        t
      end
    end
  end
end
