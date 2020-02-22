# frozen_string_literal: true

module Ticketing
  module Billing
    class Account < ApplicationRecord
      belongs_to :billable, polymorphic: true, inverse_of: :billing_account
      has_many :transfers, -> { order(created_at: :desc) },
               inverse_of: :account, autosave: true, dependent: :destroy

      validates :balance, numericality: true

      def deposit(amount, note_key)
        return if amount.zero?

        update_balance(amount)

        t = transfers.new
        t.amount = amount
        t.note_key = note_key
        t
      end

      def withdraw(amount, note_key)
        deposit(-amount, note_key)
      end

      def transfer(participant, amount, note_key, reverse_transfer = nil)
        return nil if amount.zero? || participant == self

        update_balance(-amount)

        t = transfers.new
        t.participant = participant
        t.amount = -amount
        t.note_key = note_key

        t.reverse_transfer = if reverse_transfer.nil?
                               participant.transfer(self, -amount, note_key, t)
                             else
                               reverse_transfer
                             end

        t
      end

      def outstanding?
        balance.negative?
      end

      private

      def update_balance(amount)
        self[:balance] = self[:balance] + amount
      end

      def balance=(val)
        self[:balance] = val
      end
    end
  end
end
