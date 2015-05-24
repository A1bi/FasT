module Ticketing::Billing
  class Account < BaseModel
    belongs_to :billable, polymorphic: true
    has_many :transfers, foreign_key: :sender_id

    validates_presence_of :billable
    validates :balance, numericality: { only_integer: true }

    def transfer(recipient, amount, reverse_transfer = nil)
      self[:balance] = self[:balance] - amount

      t = transfers.new
      t.sender = self
      t.recipient = recipient
      t.amount = -amount
      t.reverse_transfer = reverse_transfer
      t.save

      if reverse_transfer.nil?
        recipient.transfer(self, -amount, t)
      end

      save
    end

    private

    def balance=(val)
      self[:balance] = val
    end
  end
end
