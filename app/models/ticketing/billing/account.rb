module Ticketing::Billing
  class Account < BaseModel
    belongs_to :billable, polymorphic: true, inverse_of: :billing_account
    has_many :transfers, autosave: true, dependent: :destroy

    validates_presence_of :billable
    validates_numericality_of :balance

    def deposit(amount, note_key)
      return if amount.zero?

      update_balance(amount)

      t = transfers.new
      t.amount = amount
      t.note_key = note_key
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

      if reverse_transfer.nil?
        t.reverse_transfer = participant.transfer(self, -amount, note_key, t)
      else
        t.reverse_transfer = reverse_transfer
      end

      return t
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
