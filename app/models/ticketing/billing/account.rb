# frozen_string_literal: true

module Ticketing
  module Billing
    class Account < ApplicationRecord
      belongs_to :billable, polymorphic: true, inverse_of: :billing_account
      has_many :transfers, -> { order(created_at: :desc) },
               inverse_of: :account, dependent: :destroy

      validates :balance, numericality: true

      def deposit(amount, note_key)
        return if amount.zero?

        update_balance(amount)

        create_transfer(amount: amount, note_key: note_key)
      end

      def withdraw(amount, note_key)
        deposit(-amount, note_key)
      end

      def transfer(participant, amount, note_key, reverse_transfer = nil)
        return if amount.zero? || participant == self

        update_balance(-amount)

        create_transfer(participant: participant, amount: -amount,
                        note_key: note_key) do |t|
          t.reverse_transfer = reverse_transfer ||
                               participant.transfer(self, -amount, note_key, t)
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

      def create_transfer(attrs)
        t = transfers.new(attrs)
        yield t if block_given?
        t.save! if persisted?
        t
      end
    end
  end
end
