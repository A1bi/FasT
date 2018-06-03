module Ticketing::Billing
  class Transfer < BaseModel
    belongs_to :account
    belongs_to :participant, class_name: 'Account', optional: true, autosave: true
    belongs_to :reverse_transfer, class_name: 'Transfer', optional: true

    validates_numericality_of :amount

    def note_key
      super.to_sym
    end
  end
end
