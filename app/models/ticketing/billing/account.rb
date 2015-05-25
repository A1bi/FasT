module Ticketing::Billing
  class Account < BaseModel
    belongs_to :billable, polymorphic: true, inverse_of: :billing_account
    has_many :transfers, autosave: true

    validates_presence_of :billable
    validates_numericality_of :balance

    def deposit(amount)
      return if amount.zero?

      update_balance(amount)

      t = transfers.new
      t.amount = amount
    end

    def withdraw(amount)
      deposit(-amount)
    end

    def transfer(participant, amount, reverse_transfer = nil)
      return if amount.zero? || participant == self

      update_balance(-amount)

      t = transfers.new
      t.participant = participant
      t.amount = -amount
      t.reverse_transfer = reverse_transfer

      if reverse_transfer.nil?
        participant.transfer(self, -amount, t)
      end
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
