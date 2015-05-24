module Ticketing::Billing
  class Transfer < BaseModel
    belongs_to :sender, class_name: Account
    belongs_to :recipient, class_name: Account
    belongs_to :reverse_transfer, class_name: Transfer

    validates_presence_of :sender, :recipient, :amount
    validates :amount, numericality: { only_integer: true }
  end
end
